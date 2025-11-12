// Weather API configuration
// Using OpenWeatherMap API - you'll need to get your own free API key from https://openweathermap.org/api
const API_KEY = 'YOUR_API_KEY_HERE'; // Replace with your actual API key
const API_BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';

// DOM elements
const cityInput = document.getElementById('city-input');
const searchBtn = document.getElementById('search-btn');
const weatherData = document.getElementById('weather-data');
const errorMessage = document.getElementById('error-message');
const loading = document.getElementById('loading');

// Weather display elements
const cityName = document.getElementById('city-name');
const country = document.getElementById('country');
const temp = document.getElementById('temp');
const weatherIcon = document.getElementById('weather-icon');
const weatherDesc = document.getElementById('weather-desc');
const feelsLike = document.getElementById('feels-like');
const humidity = document.getElementById('humidity');
const windSpeed = document.getElementById('wind-speed');

// Event listeners
searchBtn.addEventListener('click', handleSearch);
cityInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        handleSearch();
    }
});

// Handle search
async function handleSearch() {
    const city = cityInput.value.trim();
    
    if (!city) {
        showError('Please enter a city name');
        return;
    }

    if (API_KEY === 'YOUR_API_KEY_HERE') {
        showError('Please add your OpenWeatherMap API key in app.js');
        return;
    }

    await getWeatherData(city);
}

// Fetch weather data from API
async function getWeatherData(city) {
    try {
        // Show loading state
        showLoading();
        hideError();
        hideWeatherData();

        const url = `${API_BASE_URL}?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=metric`;
        const response = await fetch(url);

        if (!response.ok) {
            if (response.status === 404) {
                throw new Error('City not found. Please check the spelling and try again.');
            } else if (response.status === 401) {
                throw new Error('Invalid API key. Please check your API key.');
            } else {
                throw new Error('Unable to fetch weather data. Please try again later.');
            }
        }

        const data = await response.json();
        displayWeatherData(data);
        
    } catch (error) {
        showError(error.message);
    } finally {
        hideLoading();
    }
}

// Display weather data
function displayWeatherData(data) {
    // Update city and country
    cityName.textContent = data.name;
    country.textContent = data.sys.country;

    // Update temperature
    temp.textContent = `${Math.round(data.main.temp)}°C`;

    // Update weather icon
    const iconCode = data.weather[0].icon;
    weatherIcon.src = `https://openweathermap.org/img/wn/${iconCode}@2x.png`;
    weatherIcon.alt = data.weather[0].description;

    // Update description
    weatherDesc.textContent = data.weather[0].description;

    // Update details
    feelsLike.textContent = `${Math.round(data.main.feels_like)}°C`;
    humidity.textContent = `${data.main.humidity}%`;
    windSpeed.textContent = `${data.wind.speed} m/s`;

    // Show weather data
    showWeatherData();
}

// UI helper functions
function showWeatherData() {
    weatherData.classList.remove('hidden');
}

function hideWeatherData() {
    weatherData.classList.add('hidden');
}

function showError(message) {
    errorMessage.textContent = message;
    errorMessage.classList.remove('hidden');
}

function hideError() {
    errorMessage.classList.add('hidden');
}

function showLoading() {
    loading.classList.remove('hidden');
}

function hideLoading() {
    loading.classList.add('hidden');
}

// Load default city on page load (optional)
window.addEventListener('load', () => {
    // You can uncomment the line below to load a default city on startup
    // cityInput.value = 'London';
    // handleSearch();
});
