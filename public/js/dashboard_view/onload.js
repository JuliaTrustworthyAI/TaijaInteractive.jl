/**
 * Validates the selected file and checks if it has a valid file type.
 * @returns {boolean} Returns false if the file type is invalid, otherwise returns true.
 */
function fileValidation() {
    var fileInput = document.getElementById('add-data'); 
    var filePath = fileInput.value;
 
    // Allowing file type
    var allowedExtensions = /\.csv$/;
     
    if (!allowedExtensions.exec(filePath)) {
        alert('Invalid file type');
        fileInput.value = '';
        return false;
    }
    return true;
}

function deleteElement(elementId) {
    if (!confirm('Are you sure you want to delete this element?')) {
        return;
    }

    fetch(`/dashboardelements/${elementId}/delete`, {
        method: 'DELETE',
    })
    .then(response => {
        if (response.ok) {
            const element = document.querySelector(`div[data_id='${elementId}']`);
            if (element) {
                element.remove();
            }
        }
    })
    .catch(error => {
        console.log('Error:', error);
    });
}




/**
 * @desc Handles the pointer down event to initiate dragging
 * 
 * @param {Object} positions - Object to store the positions of draggable elements
 * @param {Object} state - Object to store the dragging state and current mouse positions
 **/

const pointerDown = (positions, state) => e => {
    // If already dragging with a different pointer, do nothing
    if (state.dragging && state.pointerId !== e.pointerId) return;
    
    state.movement = false;

    const myBox = e.currentTarget.getBoundingClientRect();

    // Update the dragging state
    state.dragging = true;
    state.pointerId = e.pointerId;
    state.mouseOffsetX = e.clientX - myBox.left;
    state.mouseOffsetY = e.clientY - myBox.top;
    state.beingDragged = e.currentTarget;
};


/**
* @desc Stops dragging once the user lifts the mouse (drop)
* 
* @param positions = Handles the current draggable object's positions
* @param state = an object keeping the dragging state and current mouse positions
* 
**/

const pointerUp = (positions, state) => e => {
    // Container (big box)
    const outerBox = e.currentTarget.getBoundingClientRect();

    if (!state.dragging || state.pointerId != e.pointerId) return;
    if(state.movement == false) return;

    state.dragging = false;
    state.pointerId = null;

    const bd = state.beingDragged;
    const bdRect = bd.getBoundingClientRect();

    let newX =  bdRect.left - outerBox.left;
    let newY = bdRect.top - outerBox.top;

    var routeUrl = "/dashboardelements/" + bd.getAttribute("data_id") + "/position/" + newX + "/" + newY;
    
    fetch(routeUrl, { method: "GET"}).then(r=> !r.ok && window.alert("Drag and drop does not work"));
};


/**
* @desc Stops dragging once the mouse leaves the square. (drop)
* 
* @param positions = Handles the current draggable object's positions
* @param state = an object keeping the dragging state and current mouse positions
* 
**/

const pointerLeave = (positions, state) => e => {
    console.log("pointer leave")
    const bd = state.beingDragged;
    //const bdRect = bd.getBoundingClientRect();

    
    // Container (big box)
    const outerBox = e.currentTarget.getBoundingClientRect();


    if (!state.dragging || state.pointerId != e.pointerId) return;
    if(state.movement == false) return;

    state.dragging = false;
    state.pointerId = null;

    
    var url = window.location.href

    let newX =  bdRect.left - outerBox.left;
    let newY = bdRect.top - outerBox.top;


    var routeUrl = "/dashboardelements/" + bd.getAttribute("data_id") + "/position/" + newX + "/" + newY;

    
    fetch(routeUrl, { method: "GET"}).then(r=> !r.ok && window.alert("Drag and drop does not work"));
};



/**
 * @desc Moves the object along with the mouse while dragging flag is on
 * 
 * @param {Object} positions - Handles the current draggable object's positions
 * @param {Object} state - An object keeping the dragging state and current mouse positions
 **/

const pointerMove = (positions, state) => e => {
    if (!state.dragging || state.pointerId !== e.pointerId) return;
    if (!state.beingDragged) return;

    // Container (big box)
    const outerBox = e.currentTarget.getBoundingClientRect();

    state.movement = true;
    // Calculate the new top-left corner position of the rectangle
    let newX = e.clientX - outerBox.left - state.mouseOffsetX;
    let newY = e.clientY - outerBox.top - state.mouseOffsetY;

    // Draggable (small box)
    const bd = state.beingDragged;
    const bdRect = bd.getBoundingClientRect();

    // Ensure the draggable object stays within the bounds of the container
    if (newX < 0) newX = 0;
    if (newX > outerBox.width - bdRect.width) newX = outerBox.width - bdRect.width;
    if (newY < 0) newY = 0;
    if (newY > outerBox.height - bdRect.height) newY = outerBox.height - bdRect.height;

    // Update the draggable object's position
    bd.style.left = newX + "px";
    bd.style.top = newY + "px";

    // Update the positions object with the new coordinates
    positions[bd.getAttribute("name")] = [newX, newY];
};

/**
 * @desc Initializes the draggable element, setting its initial position and adding event listeners
 * 
 * @param {HTMLElement} el - The element to be made draggable
 * @param {Object} positions - Object to store the positions of draggable elements
 * @param {Object} state - Object to store the dragging state and current mouse positions
 * @param {DOMRect} outerBox - The bounding rectangle of the container element
 **/

function hydrateDraggable(el, positions, state, outerBox) {
    const myBox = el.getBoundingClientRect();
    const initX = myBox.left - outerBox.left;
    const initY = myBox.top - outerBox.top;

    // Store the initial position of the draggable element
    positions[el.getAttribute("name")] = [initX, initY];

    // Add event listener for the pointer down event to start dragging
    el.addEventListener("pointerdown", pointerDown(positions, state));
}

/**
 * @desc Initializes the drag container, sets up draggable elements, and adds event listeners
 * 
 * @param {HTMLElement} el - The container element that holds draggable elements
 * @param {Object} positions - Object to store the positions of draggable elements
 * @returns {Object} positions - Updated positions of draggable elements
 **/

function hydrateDragContainer(el, positions) {
    positions ??= {};

    const state = {
        dragging: false,
        pointerId: -1,
        mouseOffsetX: 0,
        mouseOffsetY: 0,
        movement: false
    };

    if (el) {
        const draggableElements = el.querySelectorAll(".draggable");

        for (let draggable of draggableElements) {
            hydrateDraggable(draggable, positions, state, el.getBoundingClientRect());
        }

        el.addEventListener("pointermove", pointerMove(positions, state));
        el.addEventListener("pointerup", pointerUp(positions, state));
        
        el.addEventListener("pointerleave", pointerLeave(positions, state));

        return positions;
    } else {
        console.error("Container element not found");
    }
}

/**
 * @desc Checks whether the model file is of the correct format.
 * 
 * 
 **/

function modelFileValidation() {

    var fileInput = document.getElementById('ModelFile'); 
    var filePath = fileInput.value;
 
    // Allowing file type
    var allowedExtensions = /\.bson$/;
     
    if (!allowedExtensions.exec(filePath)) {
        alert('Invalid file type');
        fileInput.value = '';
        return false;
    }
    return true;
}


// Function to handle overlay hiding
document.getElementById("model-info-overlay").addEventListener("click", function(event) {
    console.log(event.target)
    if (event.target === document.getElementById("model-info-overlay")) {
        document.getElementById("model-info-overlay").style.display = "none";
    }
});


// Function to handle overlay hiding
document.getElementById("dataset-info-overlay").addEventListener("click", function(event) {
    console.log(event.target)
    if (event.target === document.getElementById("dataset-info-overlay")) {
        document.getElementById("dataset-info-overlay").style.display = "none";
    }
});

function createCounter() {
    var modelForm = document.getElementById("classifier-selector");
    var modelId = modelForm.value;
    var genForm = document.getElementById("generator-selector");
    var genName = genForm.value;
    var datasetForm = document.getElementById("data-selector");
    var datasetId = datasetForm.value;
    var factual = document.getElementById("factual").value
    var target = document.getElementById("target").value

    var url = window.location.href
    var dashboardId = url.split('/')[4]
    var routeUrl = "/pool/generateCounterfactual/" + genName + "/" + modelId + "/" + datasetId + "/" + dashboardId + "/" + factual + "/" + target;
    window.location.href = routeUrl;
}

function createDatasetInfo() {
    var form = document.getElementById("data-selector-for-info")
    var datasetId = form.value;

    var url = window.location.href
    var dashboardId = url.split('/')[4]

    var routeUrl = url + "/createDatasetInfo/" + datasetId;
    fetch(routeUrl, {
        //method: 'DELETE',
    })
    .then(response => {
        if (response.ok) {
            console.log('Model info deleted successfully');
            //const element = document.querySelector(`div[data_id='${elementId}']`);
            //if (element) {
            //    element.remove();
            //}
        }
        window.location.reload();
    })
    .catch(error => {
        console.log('Error:', error);
    });
    //window.location.href = routeUrl;
}

function createModelInfo() {
    var form = document.getElementById("model-selector-for-info")
    var modelId = form.value;

    var url = window.location.href
    var dashboardId = url.split('/')[4]

    var routeUrl = dashboardId + "/createModelInfo/" + modelId;
    fetch(routeUrl, {
        //method: 'DELETE',
    })
    .then(response => {
        if (response.ok) {
            console.log('Model info deleted successfully');
            //const element = document.querySelector(`div[data_id='${elementId}']`);
            //if (element) {
            //    element.remove();
            //}
        }
        window.location.reload();
    })
    .catch(error => {
        console.log('Error:', error);
    });
    //window.location.reload();
    //window.location.href = routeUrl;
}

function toggleOptions() {
    var x = document.getElementById("options");
    if (x.style.display != "flex") {
        x.style.display = "flex";
    } else {
        x.style.display = "none";
    }
}



function openModelOverlay() {
    var x = document.getElementById("model-info-overlay");
    if (x.style.display != "flex") {
        x.style.display = "flex";
    } else {
        x.style.display = "none";
    }
}
function openDatasetOverlay() {
    var x = document.getElementById("dataset-info-overlay");
    if (x.style.display != "flex") {
        x.style.display = "flex";
    } else {
        x.style.display = "none";
    }
}

function toggleOptions() {
    var x = document.getElementById("options");
    if (x.style.display != "flex") {
        x.style.display = "flex";
    } else {
        x.style.display = "none";
    }
}


function generatePdf() {
    
    const download_button =
    document.getElementById("export-dashboard");
    
    const content =
    document.getElementById('dashboard');


    download_button.addEventListener
    ('click', async function () {
        const filename = 'data.pdf';

        try {
            const opt = {
                margin: 0,
                filename: filename,
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: window.devicePixelRatio,
    scrollY: 0,
    scrollX: 0,
    windowWidth: window.innerWidth,},
                jsPDF: {
                    unit: 'em', format: [115, 80],
                    orientation: 'portrait'
                }
            };
            html2pdf().set({
    pagebreak: { mode: ['avoid-all', 'css', 'legacy'] }
        });

            await html2pdf().set(opt).
                from(content).save();
        } catch (error) {
            console.error('Error:', error.message);
        }
    });

}
generatePdf()



function loadProperties(name) {
    document.getElementById("properties").style.display = "flex";
    var forms = document.getElementsByClassName("element-form")
    
    for (var i = 0; i < forms.length; i++) {
        forms[i].style.display = "none";
    }

    switch (name) {
        case "fineTune":
            window.alert("Not yet implemented: " + name);
            break;
        case "modelExplanation":
            document.getElementById("model-info-form").style.display = "flex";
            break;
        case "counterfactual":
            document.getElementById("counterfactual-form").style.display = "flex";
            break;
        case "dataExplanation":
            document.getElementById("dataset-info-form").style.display = "flex";
            break;
        default:
            window.alert("Not yet implemented: " + name);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    hydrateDragContainer(document.getElementById("elements"));
});

const closetButtons = document.getElementsByClassName("element-button-delete");

const closeSvg = '<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="0.5" width="32" height="32" rx="6" fill="#F87171"/><path d="M13.2957 11.7229L13.2963 11.7235L16.994 15.43L20.7043 11.7375L21.0577 12.0913L20.705 11.7369L20.7047 11.7371C21.0023 11.4403 21.4791 11.4404 21.7766 11.7375C22.0745 12.0351 22.0745 12.5126 21.7766 12.8102L21.7759 12.8108L18.0658 16.5031L21.762 20.2081C21.7621 20.2082 21.7622 20.2083 21.7623 20.2084C22.0599 20.506 22.0597 20.9833 21.762 21.2807L21.4086 20.927L21.7619 21.2807C21.6232 21.4193 21.4225 21.5 21.2331 21.5C21.0438 21.5 20.8431 21.4193 20.7043 21.2807L21.0577 20.927L20.7043 21.2807L16.9933 17.5743L13.2963 21.2801L13.2957 21.2808C13.1569 21.4193 12.9562 21.5 12.7669 21.5C12.5775 21.5 12.3768 21.4193 12.2381 21.2808L12.5914 20.927L12.238 21.2807C11.9404 20.9835 11.9401 20.5065 12.2372 20.2089C12.2375 20.2087 12.2378 20.2084 12.238 20.2081L15.9215 16.5025L12.2234 12.7956C12.2233 12.7954 12.2232 12.7953 12.2231 12.7952C11.9255 12.4976 11.9256 12.0203 12.2234 11.7229C12.521 11.4257 12.9981 11.4257 13.2957 11.7229Z" fill="white" stroke="white"/></svg>';

for (let i = 0; i < closetButtons.length; i++) {
    closetButtons[i].innerHTML = closeSvg;
}

const downloadButtons = document.getElementsByClassName("download-button");

const downloadSvg = '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M10 0C10.5523 0 11 0.447715 11 1V10.5858L14.2929 7.29289C14.6834 6.90237 15.3166 6.90237 15.7071 7.29289C16.0976 7.68342 16.0976 8.31658 15.7071 8.70711L10.7071 13.7071C10.3166 14.0976 9.68342 14.0976 9.29289 13.7071L4.29289 8.70711C3.90237 8.31658 3.90237 7.68342 4.29289 7.29289C4.68342 6.90237 5.31658 6.90237 5.70711 7.29289L9 10.5858V1C9 0.447715 9.44771 0 10 0ZM1 12C1.55228 12 2 12.4477 2 13V17C2 17.2652 2.10536 17.5196 2.29289 17.7071C2.48043 17.8946 2.73478 18 3 18H17C17.2652 18 17.5196 17.8946 17.7071 17.7071C17.8946 17.5196 18 17.2652 18 17V13C18 12.4477 18.4477 12 19 12C19.5523 12 20 12.4477 20 13V17C20 17.7957 19.6839 18.5587 19.1213 19.1213C18.5587 19.6839 17.7957 20 17 20H3C2.20435 20 1.44129 19.6839 0.87868 19.1213C0.31607 18.5587 0 17.7957 0 17V13C0 12.4477 0.447715 12 1 12Z" fill="black"/></svg>';

for (let i = 0; i < downloadButtons.length; i++) {
    downloadButtons[i].innerHTML = downloadSvg;
}

hydrateDragContainer(document.getElementById("elements"));

hydrateDragContainer(document.getElementById("elements"));




//module.exports = { fileValidation, deleteElement, pointerDown, pointerUp, pointerMove, hydrateDraggable, hydrateDragContainer, modelFileValidation, createCounter, createDatasetInfo, createModelInfo, toggleOptions, loadProperties };


