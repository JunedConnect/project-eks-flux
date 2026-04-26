import React, { useEffect, useState } from "react";
import axios from "axios";

function App() {
  const [weather, setWeather] = useState();
  const [cityName, setCityName] = useState("Banglore");
  const [inputValue, setInputValue] = useState(cityName);

  useEffect(() => {
    if (cityName) {
      axios.get(`https://goweather.herokuapp.com/weather/${cityName}`)
        .then((response) => {
          setWeather(response.data);
        })
        .catch((error) => {
          console.error(error);
          setWeather(null);
        });
    }
  }, [cityName]);

  return <div>
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-r from-blue-500 to-purple-500">
        <div className="bg-white rounded-lg shadow-lg p-6 max-w-lg w-full">
          <h1 className="text-2xl font-bold text-center mb-4"> Weather App
            <span className="text-sm font-normal ml-2">
              <a href="https://github.com/EmaniAditya" target="_blank" className="text-blue-500">
                Developed by Aditya
              </a>
            </span>
          </h1>
          <div className="flex items-center mb-4">
            <input type="text" placeholder="City Name: try 'Raipur'" value={inputValue} onChange={(e) => setInputValue(e.target.value)}
              className="flex-1 border border-gray-300 rounded-lg px-4 py-2 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
            <button onClick={() => {
                setCityName(inputValue.trim());
                setWeather("loading...");
              }}
              className="ml-2 bg-blue-500 text-white rounded-lg px-4 py-2 hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-400">
              Fetch
            </button>
          </div>
          <div>
            {weather ? (
              <div className="text-center">
                <p className="text-xl font-semibold">{cityName}</p>
                <p className="text-lg">{weather.description}</p>
                <p className="text-4xl font-bold mt-2">{weather.temperature}</p>
                <p className="text-sm text-gray-500">Wind: {weather.wind}</p>
                <h2 className="text-xl font-bold mt-4">Forecasts</h2>
                <div className="mt-2">
                  {Array.isArray(weather.forecast) && weather.forecast.length > 0 ? (
                    <div className="grid grid-cols-3 gap-4">
                      {weather.forecast.map((day, index) => (
                        <div key={index} className="p-4 bg-gray-100 rounded-lg shadow-sm">
                          <p className="text-lg font-light">Day {day.day}</p>
                          <p className="text-4xl font-bold mt-2">{day.temperature}</p>
                          <p className="text-sm text-gray-500">{day.wind}</p>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-sm text-gray-500 mt-2">No forecast data available</p>
                  )}
                </div>

              </div>
            ) : (
              <p className="text-center text-gray-500">Loading or no data available...</p>
            )}
          </div>
          <div className="text-center text-sm text-gray-500 mt-4">
            Built on <a href="https://github.com/robertoduessmann/weather-api" target="_blank" className="text-blue-500">weather-api</a>
          </div>
        </div>
      </div>
    </div>
}

export default App;
