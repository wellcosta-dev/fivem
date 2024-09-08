window.addEventListener('message', function(event) {
    if (event.data.action === 'open') {
        document.body.style.display = 'block';

        fetch('https://wds_premium/getPP', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(response => response.json())
        .then(data => {
            document.getElementById('points').innerText = data.points + ' PP';
        });
    } else if (event.data.action === 'close') {
        document.body.style.display = 'none';
    }
});

document.getElementById('closeButton').addEventListener('click', function() {
    fetch('https://wds_premium/close', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    }).then(() => {
        document.body.style.display = 'none'; // Ensure UI is hidden
    });
});
