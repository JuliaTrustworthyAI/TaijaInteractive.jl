/* --------------------- Dataset Overlay --------------------- */
let datasetFile = null;

function uploadDataset(poolId) {
    var formData = new FormData();
    formData.append('DatasetFile', datasetFile);
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/pool/' + poolId + '/create_dataset', true);
    
    xhr.onload = function () {
        if (xhr.status === 200) {
            //alert('Dataset uploaded successfully.');
            window.location.reload();
            // Optionally, you can handle success response here
        } else {
            alert('An error occurred while uploading the dataset.');
            // Optionally, you can handle error response here
        }
    };
    
    xhr.send(formData);
}


// Function to handle overlay hiding
document.getElementById("dataset-overlay").addEventListener("click", function(event) {
    console.log(event.target)
    if (event.target === document.getElementById("dataset-overlay")) {
        document.getElementById("dataset-overlay").style.display = "none";
    }
});

document.getElementById("button-dataset-import-overlay").addEventListener("click", function() {
    console.log("Open Dataset Import Overlay")
    document.getElementById("dataset-overlay").style.display = "block";
});



document.addEventListener('DOMContentLoaded', function() {
    const dropArea = document.getElementById('dataset-drop-area');
    const fileElem = document.getElementById('datasetFileElem');

    const uploadButton = document.getElementById('upload-dataset-button');

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
            datasetFile = files[0];
        }
        
        if (datasetFile != null) {
            document.getElementById("dataset-uploaded-file-container").style.display = "flex";
            document.getElementById("dataset-uploaded-file-label").innerText = datasetFile.name;//"No file uploaded";
        }

    }
});
