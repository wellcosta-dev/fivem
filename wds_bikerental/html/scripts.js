window.addEventListener('message', function(event) {
    if (event.data.action === 'show') {
        document.body.style.display = 'flex';
    } else if (event.data.action === 'hide') {
        document.body.style.display = 'none';
    }
});

document.getElementById('rentButton').addEventListener('click', function() {
    fetch('https://wds_bicaj/rentBike', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(response => response.json()).then(result => {
        if (result.success) {
            console.log('Bike rented successfully');
        } else {
            console.log('Failed to rent bike');
        }
    }).catch(err => console.error(err));
});

document.getElementById('closeButton').addEventListener('click', function() {
    fetch('https://wds_bicaj/close', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(response => response.json()).then(result => {
        if (result.success) {
            console.log('NUI closed successfully');
        } else {
            console.log('Failed to close NUI');
        }
    }).catch(err => console.error(err));
});
