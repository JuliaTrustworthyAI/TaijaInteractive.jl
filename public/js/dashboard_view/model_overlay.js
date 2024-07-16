/* --------------------- Model Overlay --------------------- */
let modelFile = null;

function uploadModel() {
    var formData = new FormData();
    formData.append('ModelFile', modelFile);
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/pool/addModel', true);
    
    xhr.onload = function () {
        if (xhr.status === 200) {
            //alert('Model uploaded successfully.');
            window.location.reload();
            // Optionally, you can handle success response here
        } else {
            alert('An error occurred while uploading the model.');
            // Optionally, you can handle error response here
        }
    };
    
    xhr.send(formData);
}

// Set the initial tab to be visible
document.getElementById("local").style.display = "flex";

document.getElementById("button-model-import-overlay").addEventListener("click", function() {
    
    console.log("Open Model Import Overlay")
    document.getElementById("model-overlay").style.display = "block";
});

// Function to handle overlay hiding
document.getElementById("model-overlay").addEventListener("click", function(event) {
    console.log(event.target)
    if (event.target === document.getElementById("model-overlay")) {
        document.getElementById("model-overlay").style.display = "none";
    }
});


function openTab(evt, tabName) {
    var i, tabcontent, tablinks;

    // Hide all tab contents
    tabcontent = document.getElementsByClassName("tab-content");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
        tabcontent[i].classList.remove("active");
    }

    // Remove the active class from all tab buttons
    tablinks = document.getElementsByClassName("tab-button");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].classList.remove("active");
    }

    // Show the current tab and add an "active" class to the button that opened the tab
    document.getElementById(tabName).style.display = "flex";
    document.getElementById(tabName).classList.add("active");
    evt.currentTarget.classList.add("active");
}

function requestModelDownload(tabName) {
    var inputId = tabName;
    var inputValue = document.getElementById(inputId + "-input").value;
    var url = "/huggingface/model/download";

    var body = {
        "huggingFaceModelId" : inputValue,
        "library" : tabName,
        "poolId" : url.split('/')[4]
    };

    fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    })
    //.then(response => response.json())
    .then((response) => {

        console.log(response);
        alert(response);

        if (response.status === 200) {
            document.getElementById("model-overlay").style.display = "block";
            window.location.reload();
        } else {
            alert("An error occurred while downloading the model.");
        }
    })
    .catch((error) => {
        console.error("Error:", error);
    });
}

document.addEventListener('DOMContentLoaded', function() {
    const dropArea = document.getElementById('model-drop-area');
    const fileElem = document.getElementById('modelFileElem');

    const uploadButton = document.getElementById('upload-model-button');

    // Prevent default drag behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, preventDefaults, false);
        document.body.addEventListener(eventName, preventDefaults, false);
    });

    // Highlight drop area when item is dragged over it
    ['dragenter', 'dragover'].forEach(eventName => {
        dropArea.addEventListener(eventName, highlight, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, unhighlight, false);
    });

    // Handle dropped files
    dropArea.addEventListener('drop', handleDrop, false);

    // Handle click to upload files
    dropArea.addEventListener('click', () => fileElem.click());

    fileElem.addEventListener('change', handleFiles, false);

    //uploadButton.addEventListener('click', uploadModel, false);

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    function highlight() {
        dropArea.classList.add('dragover');
    }

    function unhighlight() {
        dropArea.classList.remove('dragover');
    }

    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        handleFiles({ target: { files: files } });
    }

    function handleFiles(e) {
        const files = e.target.files;
        if (files.length > 0) {
            modelFile = files[0];
        }

        if (modelFile != null) {
            document.getElementById("model-uploaded-file-container").style.display = "flex";
            document.getElementById("model-uploaded-file-label").innerText = modelFile.name;//"No file uploaded";
        }
    }
});