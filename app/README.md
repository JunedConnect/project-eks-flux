# Weather App

A simple Weather App that fetches and displays live weather data and forecasts for any city using React, Tailwind CSS, and Axios.

- **Features**: 
  - Fetch weather data from an API.
  - Display current weather and a 3-day forecast.
  - User-friendly interface with dynamic updates based on the city entered.
  - Input validation with trimming of whitespace for city names.

- **Technologies**:
  - **React**: Frontend framework used to build the user interface.
  - **Tailwind CSS**: For styling the UI, providing a responsive and modern design.
  - **Axios**: For making HTTP requests to fetch weather data from the API.

- **API Endpoint**:
  - The app fetches data from this endpoint (https://goweather.herokuapp.com/weather/Bangalore)

<br>

## Local Deployment

We need to build the Docker image. This is done by running the following command:

```bash
docker build -t weather-app .
```
---

### Step 3: Run the Docker Container
After the image has been built, we run it as a container using the following command while in the root directory of the app (i.e. where the dockerfile is located):

```bash
docker run -d -p 8080:8080 weather-app
```

FYI: The default container port for this docker image is port 8080.

---

### Step 4: Test the Container
Once the container is running, open your web browser and visit:

```bash
http://localhost:8080
```