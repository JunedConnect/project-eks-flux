# Flux Management Makefile
# This Makefile provides targets for Flux bootstrap and cleanup

.PHONY: help flux-bootstrap helm-cleanup flux-uninstall crd-cleanup all-cleanup

# Default target
help:
	@echo "=================================="
	@echo " Flux Makefile - Quick Reference"
	@echo "=================================="
	@echo ""
	@echo "[Targets]"
	@echo "  flux-bootstrap     - Bootstrap Flux with GitHub (Git repo + controllers)"
	@echo "  helm-cleanup       - Delete Helm releases and Karpenter resources"
	@echo "  flux-uninstall     - Remove Flux controllers and system resources"
	@echo "  crd-cleanup        - Delete third-party CRDs (edit CRD_LIST first)"
	@echo "  all-cleanup        - Run helm-cleanup, flux-uninstall, then crd-cleanup"
	@echo ""
	@echo "[Start (install / bootstrap)]"
	@echo "  1) make flux-bootstrap GITHUB_TOKEN=your_PAT_token_here"
	@echo "     # Bootstraps Flux into the cluster"
	@echo ""
	@echo "[Take down (uninstall / cleanup) - recommended order]"
	@echo "  1) make helm-cleanup     # uninstall Helm resources"
	@echo "  2) make flux-uninstall   # remove Flux controllers/system"
	@echo "  3) make crd-cleanup      # remove third-party CRDs"
	@echo ""

# Bootstrap Flux with GitHub integration
# Usage: make flux-bootstrap GITHUB_TOKEN=your_PAT_token_here
flux-bootstrap:
	@echo "Bootstrapping Flux with GitHub integration..."
	@if [ -z "$(GITHUB_TOKEN)" ]; then \
		echo "Error: GITHUB_TOKEN is required"; \
		echo "Usage: make flux-bootstrap GITHUB_TOKEN=your_PAT_token_here"; \
		exit 1; \
	fi
	@echo "$(GITHUB_TOKEN)" | flux bootstrap github \
		--token-auth \
		--owner=junedconnect \
		--repository=project-eks \
		--branch=dev \
		--path=clusters/dev \
		--personal \
		--toleration-keys=infra
	@echo "Flux bootstrap completed"

# Delete cluster-scoped resources first, then HelmReleases (order matters)
# How to terminate karpenter related resources (https://karpenter.sh/docs/concepts/disruption/)
helm-cleanup:
	@echo "Deleting Karpenter resources..."
	@echo "Suspending Flux Kustomizations (infra & infra-config) to prevent re-creation..."
	flux suspend kustomization flux-infra -n flux-system || true
	flux suspend kustomization flux-infra-config -n flux-system || true
	@echo "  Deleting NodePools (stops any new provisioning)..."
	@sleep 5
	kubectl delete nodepools --all --all-namespaces --ignore-not-found || true
	@echo "  Deleting NodeClaims (if any still exist)..."
	@sleep 5
	kubectl delete nodeclaims --all --all-namespaces --ignore-not-found || true
	@echo "  Removing finalizers from EC2NodeClasses to ensure EC2NodeClasses can be deleted thereafter..."
	@for r in $$(kubectl get ec2nodeclasses.karpenter.k8s.aws -o name 2>/dev/null); do \
	  echo "    Patching $$r"; \
	  kubectl patch $$r --type=merge -p '{"metadata":{"finalizers":[]}}' || true; \
	done
	@echo "  Deleting EC2NodeClasses..."
	@sleep 5
	kubectl delete ec2nodeclasses --all --all-namespaces --ignore-not-found || true
	@echo "Deleting cert-manager resources..."
	@kubectl delete clusterissuer --all --ignore-not-found || true
	@echo "Deleting external-secrets resources..."
	@kubectl delete clustersecretstore --all --ignore-not-found || true
	@echo "Deleting HelmReleases (excluding external-dns) to allow DNS records to be cleaned up..."
	@kubectl get helmreleases --all-namespaces -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name --no-headers 2>/dev/null | \
	while read -r ns name; do \
	  if [ "$$name" != "external-dns" ]; then \
	    echo "  Deleting $$ns/$$name"; \
	    kubectl -n "$$ns" delete helmrelease "$$name" --ignore-not-found || true; \
	  fi; \
	done
	@echo "Waiting 30 seconds before deleting external-dns..."
	@sleep 30
	@echo "Deleting external-dns HelmRelease last..."
	@kubectl get helmreleases --all-namespaces -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name --no-headers 2>/dev/null | \
	awk '$$2=="external-dns"{print $$1" "$$2}' | while read -r ns name; do \
	  echo "  Deleting $$ns/$$name"; \
	  kubectl -n "$$ns" delete helmrelease "$$name" --ignore-not-found || true; \
	done
	@echo "Helm cleanup completed"

# Uninstall Flux controllers
flux-uninstall:
	@echo "Uninstalling Flux controllers..."
	@flux uninstall --silent
	@echo "Flux uninstall completed"

# Remove third-party CRDs
crd-cleanup:
	@echo "Removing third-party CRDs..."
	@echo "Warning: Make sure to edit CRD_LIST in this Makefile first!"
	@for crd in $(CRD_LIST); do \
		echo "Deleting CRD: $$crd"; \
		kubectl delete crd $$crd --ignore-not-found || true; \
	done
	@echo "CRD cleanup completed"

# Complete cleanup (all steps)
all-cleanup: helm-cleanup flux-uninstall crd-cleanup
	@echo "Complete cleanup finished."




# List of CRDs to delete (edit this list as needed)
# Note: Flux CRDs are removed by 'flux uninstall',
CRD_LIST = \
	certificates.cert-manager.io \
	certificaterequests.cert-manager.io \
	challenges.acme.cert-manager.io \
	clusterissuers.cert-manager.io \
	issuers.cert-manager.io \
	orders.acme.cert-manager.io \
	acraccesstokens.generators.external-secrets.io \
	cloudsmithaccesstokens.generators.external-secrets.io \
	clusterexternalsecrets.external-secrets.io \
	clustergenerators.generators.external-secrets.io \
	clusterpushsecrets.external-secrets.io \
	clustersecretstores.external-secrets.io \
	ecrauthorizationtokens.generators.external-secrets.io \
	externalsecrets.external-secrets.io \
	fakes.generators.external-secrets.io \
	gcraccesstokens.generators.external-secrets.io \
	generatorstates.generators.external-secrets.io \
	githubaccesstokens.generators.external-secrets.io \
	grafanas.generators.external-secrets.io \
	mfas.generators.external-secrets.io \
	passwords.generators.external-secrets.io \
	pushsecrets.external-secrets.io \
	quayaccesstokens.generators.external-secrets.io \
	secretstores.external-secrets.io \
	sshkeys.generators.external-secrets.io \
	stssessiontokens.generators.external-secrets.io \
	uuids.generators.external-secrets.io \
	vaultdynamicsecrets.generators.external-secrets.io \
	webhooks.generators.external-secrets.io \
	clustercompliancereports.aquasecurity.github.io \
	clusterconfigauditreports.aquasecurity.github.io \
	clusterexposedsecretreports.aquasecurity.github.io \
	clusterinfraassessmentreports.aquasecurity.github.io \
	clusterrbacassessmentreports.aquasecurity.github.io \
	clustersbomreports.aquasecurity.github.io \
	clustervulnerabilityreports.aquasecurity.github.io \
	configauditreports.aquasecurity.github.io \
	exposedsecretreports.aquasecurity.github.io \
	infraassessmentreports.aquasecurity.github.io \
	rbacassessmentreports.aquasecurity.github.io \
	sbomreports.aquasecurity.github.io \
	vulnerabilityreports.aquasecurity.github.io \
	alertmanagerconfigs.monitoring.coreos.com \
	alertmanagers.monitoring.coreos.com \
	podmonitors.monitoring.coreos.com \
	probes.monitoring.coreos.com \
	prometheusagents.monitoring.coreos.com \
	prometheuses.monitoring.coreos.com \
	prometheusrules.monitoring.coreos.com \
	scrapeconfigs.monitoring.coreos.com \
	servicemonitors.monitoring.coreos.com \
	thanosrulers.monitoring.coreos.com \
	ec2nodeclasses.karpenter.k8s.aws \
	nodeclaims.karpenter.sh \
	nodeoverlays.karpenter.sh \
	nodepools.karpenter.sh \
	dnsendpoints.externaldns.k8s.io