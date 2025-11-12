# Weather App Widget

A simple weather widget application that displays current weather information for any city using the OpenWeatherMap API.

## Features

- 🌤️ Real-time weather data
- 🔍 Search weather by city name
- 🌡️ Display temperature, feels like, humidity, and wind speed
- 🎨 Beautiful gradient UI design
- 📱 Responsive design for mobile and desktop
- ⚡ Fast and lightweight

## Setup Instructions

### 1. Get an API Key

This app uses the OpenWeatherMap API to fetch weather data. You need to get a free API key:

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Navigate to your API keys section
4. Copy your API key

### 2. Configure the App

1. Open `app.js` file
2. Find the line with `const API_KEY = 'YOUR_API_KEY_HERE';`
3. Replace `'YOUR_API_KEY_HERE'` with your actual API key:
   ```javascript
   const API_KEY = 'your_actual_api_key_here';
   ```

### 3. Run the App

Simply open `index.html` in your web browser:
- Double-click the `index.html` file, or
- Right-click and select "Open with" → your preferred browser, or
- If you prefer a local server:
  ```bash
  # Using Python 3
  python -m http.server 8000
  
  # Using Python 2
  python -m SimpleHTTPServer 8000
  
  # Using Node.js (if you have http-server installed)
  npx http-server
  ```
  Then open http://localhost:8000 in your browser

## How to Use

1. Enter a city name in the search box
2. Click the "Search" button or press Enter
3. View the current weather information for that city

## Files Structure

```
weather_app/
├── index.html    # Main HTML file with widget structure
├── style.css     # Styling and animations
├── app.js        # JavaScript logic and API integration
└── README.md     # This file
```

## Technologies Used

- HTML5
- CSS3 (with animations and gradients)
- Vanilla JavaScript (ES6+)
- OpenWeatherMap API

## API Information

This app uses the [OpenWeatherMap Current Weather Data API](https://openweathermap.org/current):
- Free tier: 60 calls/minute, 1,000,000 calls/month
- Returns current weather data including temperature, humidity, wind speed, etc.

## Browser Compatibility

Works on all modern browsers:
- Chrome
- Firefox
- Safari
- Edge

## Troubleshooting

**Error: "Please add your OpenWeatherMap API key"**
- You need to add your API key in `app.js` as described in the setup instructions

**Error: "City not found"**
- Check the spelling of the city name
- Try using the English name of the city
- Some smaller cities may not be in the database

**Error: "Invalid API key"**
- Make sure you copied the API key correctly
- Check that your API key is activated (new keys may take a few minutes)

## License

This project is open source and available under the MIT License.