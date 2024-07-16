let datasetFile = null;


document.getElementById('train-button').addEventListener('click', function() {
    const model = document.getElementById('model').value;
    const modelName = document.getElementById('model-name-input').value;
    const modelDescription = document.getElementById('model-description-input').value;

    const dataset = datasetFile;
    
    if (!dataset) {
        alert('Please upload a dataset.');
        return;
    }

    const formData = new FormData();

    formData.append('modelType', model);
    formData.append('modelName', modelName);
    formData.append('modelDescription', modelDescription);
    formData.append('dataset', dataset);

    console.log(formData);

    fetch('/model/train/counterfactuals', {
        method: 'POST',
        body: formData
    })
    .then(data => {
        console.log(data);
        if (data.status == 200) {
            document.getElementById('error').style.display = 'block';
            document.getElementById('success').style.display = 'none';
        } else {
            document.getElementById('error').style.display = 'none';
            document.getElementById('success').style.display = 'block';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        document.getElementById('error').style.display = 'block';
        document.getElementById('success').style.display = 'none';
    });
});

document.getElementById('download-button').addEventListener('click', function() {
    if (!window.trainedModel) {
        alert('No model available for download. Please train the model first.');
        return;
    }
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
            document.getElementById("uploaded-file-container").style.display = "flex";
            document.getElementById("uploaded-file-label").innerText = datasetFile.name;//"No file uploaded";
        }

        
    }
});


