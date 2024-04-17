// Get all inputs
const inputs = document.getElementsByTagName('input');
// console.log(inputs);

// Add evemt listener to each input

for (let i = 0; i < inputs.length; i++) {
    // for search add on keyup
    if (inputs[i].name === 'search') {
        inputs[i].addEventListener('keyup', runFilter);
    } else {
        inputs[i].addEventListener('change', runFilter);
    }
}


// Filter


function runFilter() {
    // Get all inputs
    const inputs = document.getElementsByTagName('input');
    // group by name
    const inputsByName = {};
    for (let i = 0; i < inputs.length; i++) {
        if (!inputsByName[inputs[i].name]) {
            inputsByName[inputs[i].name] = [];
        }
        inputsByName[inputs[i].name].push(inputs[i]);
    }
    // console.log(inputsByName);
    // get values for each
    const values = {};
    for (let name in inputsByName) {
        values[name] = [];
        for (let i = 0; i < inputsByName[name].length; i++) {
            if (inputsByName[name][i].type === 'checkbox') {
                if (inputsByName[name][i].checked) {
                    values[name].push(inputsByName[name][i].value);
                }
            } else {
                values[name].push(inputsByName[name][i].value);
            }
        }
    }

    // console.log(values);
    // get all rows
    const rows = document.getElementsByClassName('row');

    // console.log(rows);
    // loop through rows

    runFilterChecks(rows, values);

}


function runFilterChecks(rows, values) {

    for (let i = 0; i < rows.length; i++) {
        // get td cells from each row
        const cells = rows[i].getElementsByTagName('td');
        // console.log(cells);

        // if an filter exist for a cell, check if the value is in the array of values

        let show = true;

        for (let j = 0; j < cells.length; j++) {
            const id_name = cells[j].id.split('-').pop();
            // console.log(id_name);
            // break if id_name is not a known filter

            if (!values[id_name]) {
                break
            }

            if (id_name === 'search') {
                let target_text = cells[j].textContent.toLowerCase();
                let filter = values[id_name][0].toLowerCase();

                if (target_text.indexOf(filter) <= -1) {
                    show = false;
                }
            } else {
                for (let k = 0; k < values[id_name].length; k++) {
                    if (values[id_name][k].toLowerCase() === cells[j].textContent.toLowerCase()) {
                        show = true;
                        break;
                    } else {
                        show = false;
                    }
                }
            }
        }

        if (show) {
            // give class "visible"
            rows[i].style.display = '';
        } else {
            rows[i].style.display = 'none';
        }


    }
}


runFilter()