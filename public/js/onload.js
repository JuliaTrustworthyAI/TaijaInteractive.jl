// Get the header element
const header = document.getElementById('header');

// Set the inner HTML of the header
header.innerHTML = `
<div id="taija">
    <a href="/" id="taija">Taija</a>
</div>
<div id="menu-buttons">
    <a href="/pool" class="link divider">My Boards</a>
    <a href="/model/train" class="link divider">Train Model</a>
    <a href="/help" class="link divider">Help</a>
    <div class="divider">
        <a id="make-dashboard-button" href="/pool" class="button primary-button">Make A Board</a>
    </div>
    
    
</div>`;

// Get the footer element
const footer = document.createElement('footer');

// Set the inner HTML of the footer
footer.innerHTML = `
<div id="taijaInteractive">TaijaInteractive</div>

<div id="socials">
    <a href="facebook.com">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI5NiIgaGVpZ2h0PSI5NiIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBmaWxsPSJjdXJyZW50Q29sb3IiIGQ9Ik0yMiAxMmMwLTUuNTItNC40OC0xMC0xMC0xMFMyIDYuNDggMiAxMmMwIDQuODQgMy40NCA4Ljg3IDggOS44VjE1SDh2LTNoMlY5LjVDMTAgNy41NyAxMS41NyA2IDEzLjUgNkgxNnYzaC0yYy0uNTUgMC0xIC40NS0xIDF2MmgzdjNoLTN2Ni45NWM1LjA1LS41IDktNC43NiA5LTkuOTUiLz48L3N2Zz4=" alt="facebook">
    </a>
    <a href="linkedin.com">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI5NiIgaGVpZ2h0PSI5NiIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBmaWxsPSJjdXJyZW50Q29sb3IiIGQ9Ik0xOSAzYTIgMiAwIDAgMSAyIDJ2MTRhMiAyIDAgMCAxLTIgMkg1YTIgMiAwIDAgMS0yLTJWNWEyIDIgMCAwIDEgMi0yem0tLjUgMTUuNXYtNS4zYTMuMjYgMy4yNiAwIDAgMC0zLjI2LTMuMjZjLS44NSAwLTEuODQuNTItMi4zMiAxLjN2LTEuMTFoLTIuNzl2OC4zN2gyLjc5di00LjkzYzAtLjc3LjYyLTEuNCAxLjM5LTEuNGExLjQgMS40IDAgMCAxIDEuNCAxLjR2NC45M3pNNi44OCA4LjU2YTEuNjggMS42OCAwIDAgMCAxLjY4LTEuNjhjMC0uOTMtLjc1LTEuNjktMS42OC0xLjY5YTEuNjkgMS42OSAwIDAgMC0xLjY5IDEuNjljMCAuOTMuNzYgMS42OCAxLjY5IDEuNjhtMS4zOSA5Ljk0di04LjM3SDUuNXY4LjM3eiIvPjwvc3ZnPg==" alt="linkedin">
    </a>
    <a id="youtube" href="youtube.com">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI5NiIgaGVpZ2h0PSI5NiIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBmaWxsPSJjdXJyZW50Q29sb3IiIGQ9Im0xMCAxNWw1LjE5LTNMMTAgOXptMTEuNTYtNy44M2MuMTMuNDcuMjIgMS4xLjI4IDEuOWMuMDcuOC4xIDEuNDkuMSAyLjA5TDIyIDEyYzAgMi4xOS0uMTYgMy44LS40NCA0LjgzYy0uMjUuOS0uODMgMS40OC0xLjczIDEuNzNjLS40Ny4xMy0xLjMzLjIyLTIuNjUuMjhjLTEuMy4wNy0yLjQ5LjEtMy41OS4xTDEyIDE5Yy00LjE5IDAtNi44LS4xNi03LjgzLS40NGMtLjktLjI1LTEuNDgtLjgzLTEuNzMtMS43M2MtLjEzLS40Ny0uMjItMS4xLS4yOC0xLjljLS4wNy0uOC0uMS0xLjQ5LS4xLTIuMDlMMiAxMmMwLTIuMTkuMTYtMy44LjQ0LTQuODNjLjI1LS45LjgzLTEuNDggMS43My0xLjczYy40Ny0uMTMgMS4zMy0uMjIgMi42NS0uMjhjMS4zLS4wNyAyLjQ5LS4xIDMuNTktLjFMMTIgNWM0LjE5IDAgNi44LjE2IDcuODMuNDRjLjkuMjUgMS40OC44MyAxLjczIDEuNzMiLz48L3N2Zz4=" alt="youtube">
    </a>
    <a href="instagram.com">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI5NiIgaGVpZ2h0PSI5NiIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBmaWxsPSJjdXJyZW50Q29sb3IiIGQ9Ik03LjggMmg4LjRDMTkuNCAyIDIyIDQuNiAyMiA3Ljh2OC40YTUuOCA1LjggMCAwIDEtNS44IDUuOEg3LjhDNC42IDIyIDIgMTkuNCAyIDE2LjJWNy44QTUuOCA1LjggMCAwIDEgNy44IDJtLS4yIDJBMy42IDMuNiAwIDAgMCA0IDcuNnY4LjhDNCAxOC4zOSA1LjYxIDIwIDcuNiAyMGg4LjhhMy42IDMuNiAwIDAgMCAzLjYtMy42VjcuNkMyMCA1LjYxIDE4LjM5IDQgMTYuNCA0em05LjY1IDEuNWExLjI1IDEuMjUgMCAwIDEgMS4yNSAxLjI1QTEuMjUgMS4yNSAwIDAgMSAxNy4yNSA4QTEuMjUgMS4yNSAwIDAgMSAxNiA2Ljc1YTEuMjUgMS4yNSAwIDAgMSAxLjI1LTEuMjVNMTIgN2E1IDUgMCAwIDEgNSA1YTUgNSAwIDAgMS01IDVhNSA1IDAgMCAxLTUtNWE1IDUgMCAwIDEgNS01bTAgMmEzIDMgMCAwIDAtMyAzYTMgMyAwIDAgMCAzIDNhMyAzIDAgMCAwIDMtM2EzIDMgMCAwIDAtMy0zIi8+PC9zdmc+" alt="instagram">
    </a>
</div>
`;


// Insert the header and footer into the page
document.body.prepend(header);
document.body.append(footer);

// Add this function to the existing code
function editDashboardName(dashboardId, currentName) {
    var newName = prompt("Enter the new name for the dashboard:", currentName);
    if (newName !== null && newName !== "") {
        updateDashboardName(dashboardId, newName);
    }
}

function updateDashboardName(dashboardId, newName) {
    fetch("/pool/" + dashboardId + "/update", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({ title: newName })
    }).then(response => {
        if (response.ok) {
            window.location.reload();
        } else {
            response.text().then(t => alert("An error occurred \\n\\n" + t));
        }
    });
}


