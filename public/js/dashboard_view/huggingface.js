/* ------------------- Hugging Face Login Overlay ------------------- */

// Create the overlay
const loginOverlay = document.createElement("div");
loginOverlay.id = "login-overlay";
loginOverlay.className = "overlay";

// Create the overlay content
const loginOverlayContent = document.createElement("div");
loginOverlayContent.id = "login-overlay-content"
loginOverlayContent.className = "overlay-content";
loginOverlayContent.style.gap = "0px";

const loginOverlayTitle = document.createElement("h2");
loginOverlayTitle.id = "huggingface-login-title";
loginOverlayTitle.textContent = "Login to Hugging Face";

const loginOverlayFormGroup = document.createElement("div");
loginOverlayFormGroup.className = "form-group";
loginOverlayFormGroup.style.alignSelf = "center";

const loginOverlayFormLabel = document.createElement("label");
loginOverlayFormLabel.className = "form-label";
loginOverlayFormLabel.textContent = "HuggingFace API Key";

const loginOverlayFormInput = document.createElement("input");
loginOverlayFormInput.id = "api-key";
loginOverlayFormInput.type = "text";
loginOverlayFormInput.placeholder = "Enter API Key";


const loginOverlayInput = document.createElement("input");


const loginOverlayLoginButton = document.createElement("button");
loginOverlayLoginButton.id = "login-button";
loginOverlayLoginButton.textContent = "Login";

const errorMessage = document.createElement("p");
errorMessage.id = "error-message";
errorMessage.style.color = "red";
errorMessage.style.display = "none";
errorMessage.textContent = "Invalid API Key. Please try again.";

loginOverlayFormGroup.appendChild(loginOverlayFormLabel);
loginOverlayFormGroup.appendChild(loginOverlayFormInput);

// Append elements to the overlay content
loginOverlayContent.appendChild(loginOverlayTitle);
loginOverlayContent.appendChild(loginOverlayFormGroup);
loginOverlayContent.appendChild(loginOverlayLoginButton);
loginOverlayContent.appendChild(errorMessage);

// Append overlay content to the overlay
loginOverlay.appendChild(loginOverlayContent);

// Append overlay to the body
document.body.appendChild(loginOverlay);


// Function to show the over'lay
function showLoginOverlay() {
    document.getElementById("login-overlay").style.display = "block";
}

// Function to hide the overlay
function hideLoginOverlay() {
    document.getElementById("login-overlay").style.display = "none";
    overlay.style.display = "none";
    errorMessage.style.display = "none";
}

function showLoginErrorMessage() {
    errorMessage.style.display = "block";
}


function loginHuggingface(key) {
    if (!validateApiKey(key)) {
        console.log("Front-end validation failed")
        showLoginErrorMessage();
        return;
    }

    fetch('/huggingface/login', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ api_key: key })
    })
    .then(response => {
        console.log(response);

        if (response.status === 200) {
            //return response.json();
            checkHuggingfaceKey();
            hideLoginOverlay();
        } else if (response.status === 401) {
            checkHuggingfaceKey();
            showLoginErrorMessage();
            throw new Error('Unauthorized');
        } else {
            checkHuggingfaceKey();
            throw new Error('Unexpected response');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        errorMessage.style.display = "block";
    });
}

function getHuggingfaceModel(model) {
    fetch('/huggingface/model', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ model: model })
    })
    .then(response => {
        console.log(response);

        if (response.status === 200) {
            return response.json();
        } else if (response.status === 401) {
            showOverlay();
            throw new Error('Unauthorized');
        } else {
            throw new Error('Unexpected response');
        }
    })
    .then(data => {
        console.log(data);
    })
    .catch(error => {
        console.error('Error:', error);
    });

}

function checkHuggingfaceKey() {
    Array.from(document.getElementsByClassName("huggingface-status-circle")).forEach(element => element.style.backgroundColor = "white");

    fetch('/huggingface/is_logged_in')
    .then(response => {
        if (response.status === 200) {
            Array.from(document.getElementsByClassName("huggingface-status-circle")).forEach(element => element.style.backgroundColor = "green");
            //return true;
            //huggingface_check_button.style.backgroundColor = "green";
        } else if (response.status === 401) {
            Array.from(document.getElementsByClassName("huggingface-status-circle")).forEach(element => element.style.backgroundColor = "red");
            return false;
            //huggingface_check_button.style.backgroundColor = "red";
        } else {
            Array.from(document.getElementsByClassName("huggingface-status-circle")).forEach(element => element.style.backgroundColor = "red");
            return false;
            //throw new Error('Unexpected response');
        }
    })
    .catch(error => {
        Array.from(document.getElementsByClassName("huggingface-status-circle")).forEach(element => element.style.backgroundColor = "red");
        console.error('Error:', error);
    });
}

function validateApiKey(apiKey) {
    const firstTwoSymbols = apiKey.substring(0, 2);
    return firstTwoSymbols === "hf" && apiKey.length === 37;
}

function updateHuggingfaceStatus() {

    Array.from(document.getElementsByClassName("huggingface-status-circle")).forEach(element => element.style.color = "white");
    
    if (checkHuggingfaceKey()) {
        Array.from(document.getElementsByClassName("huggingface-status-circle")).forEach(element => element.style.color = "green");
    } else {
        Array.from(document.getElementsByClassName("huggingface-status-circle")).forEach(element => element.style.color = "red");
    }
}

/* ------------------- Event Listeners ------------------- */

// Function to handle login button click
loginOverlayLoginButton.addEventListener("click", function() {
    const apiKey = document.getElementById("api-key").value;

    // Send API key to backend
    loginHuggingface(apiKey);
});

// Function to handle overlay hiding
loginOverlay.addEventListener("click", function(event) {
    console.log(event.target)
    if (event.target === loginOverlay) {
        hideLoginOverlay();
    }
});



updateHuggingfaceStatus();
