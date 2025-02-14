function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('collapsed');
}

async function loadContent(route) {
    try {
        const response = await fetch(route);
        if (!response.ok) {
            throw new Error(`Network response was not ok (${response.status})`);
        }
        const html = await response.text();
        document.getElementById('content').innerHTML = html;
    } catch (error) {
        console.error('Error loading content:', error);
        document.getElementById('content').innerHTML = `<p>Error loading content.</p>`;
    }
}

let currentRow = null;

function filterTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toUpperCase();
    var table = document.getElementById("ingredientsTable");
    var tr = table.getElementsByTagName("tr");

    for (var i = 1; i < tr.length; i++) { 
        var tds = tr[i].getElementsByTagName("td");
        var rowMatch = false;

        for (var j = 0; j < 3 && j < tds.length; j++) {
            var txtValue = tds[j].textContent || tds[j].innerText;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                rowMatch = true;
                break;
            }
        }
        tr[i].style.display = rowMatch ? "" : "none";
    }
}

function editRow(button) {
    currentRow = button.parentNode.parentNode;
    var cells = currentRow.getElementsByTagName("td");
    
    document.getElementById("editEnglish").value = cells[0].innerText;
    document.getElementById("editSpanish").value = cells[1].innerText;
    document.getElementById("editCatalan").value = cells[2].innerText;
    document.getElementById("editCalories").value = cells[3].innerText;
    document.getElementById("editCarbs").value = cells[4].innerText;
    document.getElementById("editProtein").value = cells[5].innerText;
    document.getElementById("editFat").value = cells[6].innerText;
    document.getElementById("editFiber").value = cells[7].innerText;
    document.getElementById("editGlutenFree").checked = cells[8].innerText.toLowerCase() === 'true';
    document.getElementById("editVegan").checked = cells[9].innerText.toLowerCase() === 'true';
    document.getElementById("editVegetarian").checked = cells[10].innerText.toLowerCase() === 'true';

    document.getElementById("editModal").style.display = "block";
}

function saveChanges() {
    if (currentRow) {
        showLoading();

        const ingredientData = {
            id: document.getElementById("editId").innerText,
            english: document.getElementById("editEnglish").value,
            spanish: document.getElementById("editSpanish").value,
            catalan: document.getElementById("editCatalan").value,
            nutritional_values_per_100g: {
                calories: parseInt(document.getElementById("editCalories").value),
                carbohydrates_g: parseFloat(document.getElementById("editCarbs").value),
                protein_g: parseFloat(document.getElementById("editProtein").value),
                fat_g: parseFloat(document.getElementById("editFat").value),
                fiber_g: parseFloat(document.getElementById("editFiber").value),
            },
            is_gluten_free: document.getElementById("editGlutenFree").checked,
            is_vegan: document.getElementById("editVegan").checked,
            is_vegetarian: document.getElementById("editVegetarian").checked,
        };

        fetch("http://localhost:8080/ingredient", {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + getCookie("token")
            },
            body: JSON.stringify(ingredientData),
        })
        .then(response => {
            hideLoading();
            if (response.ok) {
                document.getElementById("editModal").style.display = "none";
                return response.json();
            } else {
                return response.text().then(text => { throw new Error(text) });
            }
        })
        .then(data => {
            var cells = currentRow.getElementsByTagName("td");
            cells[0].innerText = data.english;
            cells[1].innerText = data.spanish;
            cells[2].innerText = data.catalan;
            cells[3].innerText = data.nutritionalValuesPer100G.calories;
            cells[4].innerText = data.nutritionalValuesPer100G.carbohydratesG;
            cells[5].innerText = data.nutritionalValuesPer100G.proteinG;
            cells[6].innerText = data.nutritionalValuesPer100G.fatG;
            cells[7].innerText = data.nutritionalValuesPer100G.fiberG;
            cells[8].innerText = data.isGlutenFree ? "true" : "false";
            cells[9].innerText = data.isVegan ? "true" : "false";
            cells[10].innerText = data.isVegetarian ? "true" : "false";
        })
        .catch(error => {
            console.error("Error saving ingredient:", error);
            showError(error);
        });
    }
}

function closeModal() {
    document.getElementById("editModal").style.display = "none";
}

function removeRow(button) {
    var row = button.parentNode.parentNode;
    if (confirm("Are you sure you want to remove this row?")) {
        row.parentNode.removeChild(row);
    }
}

function showLoading() {
    let loadingElement = document.createElement("div");
    loadingElement.id = "loadingIndicator";
    loadingElement.innerHTML = `<i class="fas fa-spinner fa-spin"></i> Loading...`;
    loadingElement.style.textAlign = "center";
    loadingElement.style.marginTop = "10px";
    document.querySelector(".modal-footer").prepend(loadingElement);
}

function hideLoading() {
    const loadingElement = document.getElementById("loadingIndicator");
    if (loadingElement) {
        loadingElement.remove();
    }
}

function getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    return parts.length === 2 ? parts.pop().split(';').shift() : null;
}
