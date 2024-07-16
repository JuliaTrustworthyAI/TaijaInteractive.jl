/* Board Manipulations */

function deleteBoard(dashboardId) {
    fetch("/pool/" + dashboardId + "/delete/", {
        method: "DELETE",
    }).then(response => {
        if (response.ok) {
            window.location.reload();
        } else {
            response.text().then(t => alert("An error occurred: " + t));
        }
    });
}

function addBoard() {
    fetch("/pool/create", {
        method: "POST",
        enctype: "multipart/form-data"
    }).then(response => {
        if (response.ok) {
            window.location.reload();
        } else {
            alert(response.ok)
            response.text().then(t => alert("An error occurred: " + t));
        }
    })
}

function searchBoard() {
    let input = document.getElementById('searchbar').value
    input = input.toLowerCase();
    let x = document.getElementsByClassName('item');

    for (i = 0; i < x.length; i++) {
        if (!x[i].textContent.toLowerCase().includes(input)) {
            x[i].style.display = "none";
        } else {
            x[i].style.display = "flex";
        }
    }
}

function sortBoards() {
    var type = document.getElementById("sortbar").value;

    var sort_by_name = function(a, b) {
        var namea = a.getAttribute("data-id").split(";")[1];
        var nameb = b.getAttribute("data-id").split(";")[1];
        return namea.toLowerCase().localeCompare(nameb.toLowerCase());
    };

    var sort_by_date = function(a, b) {
        var datea = a.getAttribute("data-id").split(";")[2];
        var dateb = b.getAttribute("data-id").split(";")[2];
        return datea.toLowerCase().localeCompare(dateb.toLowerCase());
    };

    var list = Array.from(document.getElementsByClassName("item"));
    console.log(list);
    switch (type) {
        case "name":
            list.sort(sort_by_name);
            break;
        case "date":
            list.sort(sort_by_date);
            break;
        default:
            console.log("unknown sorting type: " + String(type));
            return;
    }

    var parent = list[0].parentNode;
    list.forEach(function(item) {
        parent.appendChild(item);
    });
}

function initializeCarousel(itemWidth, padding) {
    const prev = document.getElementById('left');
    const next = document.getElementById('right');
    const list = document.getElementById('item-list');

    prev.addEventListener('click', () => {
        list.scrollLeft -= itemWidth + padding;
    });

    next.addEventListener('click', () => {
        list.scrollLeft += itemWidth + padding;
    });
}

function initializeDragCarousel(itemWidth) {
    const carousel = document.getElementById("item-list");
    const wrapper = document.getElementById("carousel-container");

    let isDragging = false,
        startX,
        startScrollLeft,
        timeoutId;

    function dragStart(e) {
        isDragging = true;
        carousel.classList.add("dragging");
        startX = e.pageX;
        startScrollLeft = carousel.scrollLeft;
    };

    const dragging = (e) => {
        if (!isDragging) return;

        const newScrollLeft = startScrollLeft - (e.pageX - startX);

        if (newScrollLeft <= 0 || newScrollLeft >=
            carousel.scrollWidth - carousel.offsetWidth) {
            isDragging = false;
            return;
        }

        carousel.scrollLeft = newScrollLeft;
    };

    const dragStop = () => {
        isDragging = false;
        carousel.classList.remove("dragging");
    };

    const autoPlay = () => {
        if (window.innerWidth < 800) return;

        const totalCardWidth = carousel.scrollWidth;
        const maxScrollLeft = totalCardWidth - carousel.offsetWidth;

        if (carousel.scrollLeft >= maxScrollLeft) return;

        timeoutId = setTimeout(() =>
            carousel.scrollLeft += itemWidth, 2500);
    };

    carousel.addEventListener("mousedown", dragStart);
    carousel.addEventListener("mousemove", dragging);
    document.addEventListener("mouseup", dragStop);

    wrapper.addEventListener("mouseenter", () => clearTimeout(timeoutId));
    wrapper.addEventListener("mouseleave", autoPlay);
}

function initializeSearch() {
    let key_pressed = document.getElementById('searchbar');
    key_pressed.addEventListener("keyup", searchBoard);
}

function initializeButtons() {
    document.getElementById("button-create-dashboard").addEventListener("click", () => {
        addBoard();
    });

    for (let deleteButton of document.querySelectorAll(".delete")) {
        deleteButton.addEventListener("click", e => {
            e.preventDefault();

            const dashboardId = e.target.dataset.id;

            deleteBoard(dashboardId);
        });
    }
}

document.addEventListener("DOMContentLoaded", () => {
    console.log("DOM loaded");
    initializeCarousel(150, 10);
    initializeDragCarousel(150);
    initializeSearch();
    initializeButtons();
});

module.exports = {
    deleteBoard, addBoard, searchBoard, sortBoards,
    initializeCarousel, initializeDragCarousel,
    initializeSearch, initializeButtons
};
