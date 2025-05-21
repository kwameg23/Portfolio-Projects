// This function fetches location names from the Flask backend
async function getLocations() {
    // Send GET request to Flask route
    const res = await fetch("http://127.0.0.1:5000/get_location_names");

    // Convert the response to JSON
    const data = await res.json();

    // Grab the <select> element in the HTML
    const locationSelect = document.getElementById("location");

    // Clear existing options
    locationSelect.innerHTML = "";

    // Add each location as an <option>
    data.locations.forEach(loc => {
        const opt = document.createElement("option");
        opt.value = loc;
        opt.text = loc;
        locationSelect.appendChild(opt);
    });
}
async function getEstimatedPrice() {
    // Get values entered by the user
    const sqft = document.getElementById("sqft").value;
    const location = document.getElementById("location").value;
    const bhk = document.getElementById("bhk").value;
    const bath = document.getElementById("bath").value;

    // Create form data to send in the POST request
    const formData = new FormData();
    formData.append("total_sqft", sqft);
    formData.append("location", location);
    formData.append("bhk", bhk);
    formData.append("bath", bath);

    // Send POST request to Flask endpoint with the form data
    const res = await fetch("http://127.0.0.1:5000/predict_home_price", {
        method: "POST",
        body: formData
    });

    // Parse the JSON response
    const result = await res.json();

    // Grab the result display area
    const resultDiv = document.getElementById("priceResult");

    // Display result or error message
    if (res.ok) {
        resultDiv.innerText = `Estimated Price: ₹ ${result.estimated_price} lakhs`;
    } else {
        resultDiv.innerText = `Error: ${result.error}`;
    }
}