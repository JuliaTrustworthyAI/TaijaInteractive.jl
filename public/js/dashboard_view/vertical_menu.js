const vertical_menu_toggle = document.getElementById('vertical-menu-toggle')
const vertical_menu_toggle_text = document.getElementById('vertical-menu-toggle-text').children[0]
const vertical_menu_inner = document.getElementById('inner-vertical-menu')
const vertical_menu = document.getElementById('vertical-menu')

vertical_menu_toggle.addEventListener('click', () => {
    if (vertical_menu_inner.style.display == 'none') {
        vertical_menu_inner.style.display = 'flex';
        vertical_menu_toggle_text.innerHTML = 'Collapse Menu';
        vertical_menu.style.zIndex = '12';
    } else {
        vertical_menu_inner.style.display = 'none'
        vertical_menu_toggle_text.innerHTML = 'Extend Menu';
        vertical_menu.style.zIndex = '0';
    }
})

document.addEventListener('DOMContentLoaded', function () {
    console.log('DOM loaded');
    // Add an event listener to the form submission
    const forms = document.getElementsByClassName('right-element-form');
    for (let i = 0; i < forms.length; i++) {
        const form= forms[i]
    form.addEventListener('submit', function (event) {
        event.preventDefault(); // Prevent the default form submission

        // Create a FormData object from the form
        const formData = new FormData(form);
        console.log(formData)
        console.log(form.action)
        // Send the form data using the fetch API
        fetch(form.action, {
            method: form.method,
            body: formData,
        })
        .then(response => {
            console.log(response)
            if (!response.ok) {
                throw new Error('Network response was not ok ' + response.statusText);
            }
            return response.text(); // or response.text() if the response is not JSON
        })
        .then(data => {
            console.log('Form submitted successfully:', data);
            window.location.reload();
            // Handle successful form submission here
        })
        .catch(error => {
            console.error('There was a problem with the form submission:', error);
            // Handle form submission error here
        });
    });
}
});

const formPrefix = "element-handler-form-";

let currMenu = null;

// Link every element button to the corresponding form
document.querySelectorAll('.element-button').forEach(button => {
    button.addEventListener('click', () => {
        // Get the new menu identifier
        menuIdentifier = button.getAttribute('data-id');

        if (currMenu == null) {
            // If no menu had been selected, select the new menu
            document.getElementById(formPrefix + menuIdentifier).style.display = '';
            currMenu = menuIdentifier;

        } else if (currMenu == menuIdentifier) {
            // If the same menu was selected, collapse the menu
            document.getElementById(formPrefix + menuIdentifier).style.display = 'none';

            currMenu = null;
        } else {
            // If a different menu has been selected, swap their displays
            document.getElementById(formPrefix + currMenu).style.display = 'none';
            document.getElementById(formPrefix + menuIdentifier).style.display = '';

            currMenu = menuIdentifier;
        }

    });
});


const dataSelectors = document.getElementsByName('dataset')

function loadSpecialSelectors() {
   fetch('/database/datasets', {method: 'GET'}).then(
    response => {
        if (response.ok) {return response;} else {throw new Error("could not fetch datasets.");}
    }
   ).then(
    response => {
        return response.json();
    }
   ).then(
    datasets => {
        document.querySelectorAll('.dataset').forEach(x => {
            datasets.forEach(dataset => {
                x.appendChild(new Option(dataset.name + "." + dataset.format, dataset.id.value));
            });
        });
        dataSelectors.forEach(dataSelector => {
            fetchLabels(dataSelector.value);
        });
        
    }
   ).catch(error => {
        console.log('Error:', error);
    });

    fetch('/database/models', {method: 'GET'}).then(
        response => {
            if (response.ok) {return response;} else {throw new Error("could not fetch models.");}
    }).then(
    response => {
        return response.json();
    }).then(
    models => {
        document.querySelectorAll('.model').forEach(x => {
            models.forEach(model => {
                x.appendChild(new Option(model.name + "."+ model.format + " (" + model.type + ")", model.id.value));
            });
        });
    }).catch(error => {
        console.log('Error:', error);
    });
}

const formLabels = document.getElementsByClassName('form-label');
for (let i = 0; i < formLabels.length; i++) {
    formLabels[i].textContent = formLabels[i].textContent.toUpperCase();
}


loadSpecialSelectors()


dataSelectors.forEach(dataSelector => {
    dataSelector.addEventListener('change', function() {
        fetchLabels(dataSelector.value);
    });
});

function fetchLabels(datasetId) {
    console.log(datasetId);
    fetch(`/labels/${datasetId}`)
        .then(response => response.json())
        .then(labels => {
            console.log("Populating labels")
            populateComboBox('target', labels);
            populateComboBox('factual', labels);
        })
        .catch(error => console.error('Error fetching labels:', error));
}

function populateComboBox(selectName, labels) {
    const selects = document.getElementsByName(selectName);

    selects.forEach(select => {
        select.innerHTML = '';
        labels.forEach(label => {
            const option = document.createElement('option');
            option.value = label;
            option.text = label;
            select.appendChild(option);
        });
    });
}
