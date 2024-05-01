


var Vehicle

window.addEventListener("message", function (event) {
    switch (event.data.action) {
        case "display":

            if (event.data.display === false) {
                $(".container-conce").fadeOut(500)
            } else {
                $(".container-conce").fadeIn(1000)
                document.getElementById('titulo').textContent = event.data.title
            }

            break

        case "update":
            Vehicle = event.data.data
            document.getElementById('marca').textContent = event.data.data.marca
            document.getElementById('precio').textContent = event.data.data.price + ' $'
            document.getElementById('modelo').textContent = formatModel(event.data.data.model)
            document.getElementById('categoria').textContent = formatModel(event.data.data.category)
            document.getElementById('velocidad').textContent = event.data.data.maxsped + ' Kmh'
            document.getElementById('asientos').textContent = event.data.data.seats + ' Plazas'

            break
        case "update-cat":
            document.getElementById('categoria').textContent = formatModel(event.data.cate)
            break
    }
})


document.addEventListener('DOMContentLoaded', function () {

    var containerAdmin = document.querySelector('.container-admin');

    if (getComputedStyle(containerAdmin).display === 'none') {


        var isMouseDown = false;

        var lastMouseX = 0;

        document.querySelector('.move').addEventListener('mousedown', function () {
            isMouseDown = true;
        });

        document.addEventListener('mouseup', function () {
            isMouseDown = false;
        });

        document.addEventListener('mouseleave', function () {
            isMouseDown = false;
        });

        document.querySelector('.move').addEventListener('mousemove', function (event) {
            if (isMouseDown) {
                var mouseX = event.clientX;
                if (mouseX > lastMouseX) {
                    LuaCallBack(function (retval) { }, 'focus_conce', { action: 'rotate-right' })
                } else if (mouseX < lastMouseX) {
                    LuaCallBack(function (retval) { }, 'focus_conce', { action: 'rotate-left' })
                }
                lastMouseX = mouseX;
            }
        });

        document.querySelector('.move').addEventListener('wheel', function (event) {
            if (event.deltaY > 0) {
                LuaCallBack(function (retval) { }, 'focus_conce', { action: 'zoom-' })
            } else if (event.deltaY < 0) {
                LuaCallBack(function (retval) { }, 'focus_conce', { action: 'zoom+' })
            }
        });
        document.querySelector('.comprar').addEventListener('click', function () {
            const color1 = document.getElementById('color1').value;
            const color2 = document.getElementById('color2').value;
            const rgbColor1 = hexToRgb(color1);
            const rgbColor2 = hexToRgb(color2);
            LuaCallBack(function (retval) { }, 'buy_Vehicle', { vehicle: Vehicle, color1: rgbColor1, color2:rgbColor2 })
        });
        document.querySelector('.izquierda-categoria').addEventListener('click', function () {
            LuaCallBack(function (retval) { }, 'focus_conce', { action: 'up' })
        });
        document.querySelector('.derecha-categoria').addEventListener('click', function () {
            LuaCallBack(function (retval) { }, 'focus_conce', { action: 'down' })
        });

        document.querySelector('.derecha-cambiar').addEventListener('click', function () {
            LuaCallBack(function (retval) { }, 'focus_conce', { action: 'right' })
        });

        document.querySelector('.izquierda-cambiar').addEventListener('click', function () {
            LuaCallBack(function (retval) { }, 'focus_conce', { action: 'left' })
        });
        document.querySelector('.cerrar').addEventListener('click', function () {
            LuaCallBack(function (retval) { }, 'focus_conce', { action: 'close' })
        });

        const color1Input = document.getElementById('color1');
        const color2Input = document.getElementById('color2');


        color1Input.addEventListener('input', function () {
            const rgbValues = hexToRgb(this.value);
            LuaCallBack(function (retval) { }, 'focus_conce', { action: 'color1', color: rgbValues })
        });

        color2Input.addEventListener('input', function () {
            const rgbValues = hexToRgb(this.value);
            LuaCallBack(function (retval) { }, 'focus_conce', { action: 'color2', color: rgbValues })
        });


    }
})

function hexToRgb(hex) {
    hex = hex.replace(/^#/, '');
    const bigint = parseInt(hex, 16);
    const r = (bigint >> 16) & 255;
    const g = (bigint >> 8) & 255;
    const b = bigint & 255;
    return { r, g, b };
}


document.onkeyup = function (data) {
    var containerAdmin = document.querySelector('.container-admin');

    if ((data.which == 27 || data.which == 8) && getComputedStyle(containerAdmin).display === 'none') {
        LuaPost('focus_conce', { action: 'close' })
    }
}

document.onkeydown = function (data) {
    var containerAdmin = document.querySelector('.container-admin');
    if (data.which == 87 && getComputedStyle(containerAdmin).display === 'none') {
        LuaPost('focus_conce', { action: 'acelerar' })
    }
}


function FocusPost(action) {
    $.post(`https://${GetParentResourceName()}/focus_conce`, JSON.stringify({ action: action }));
}

function formatModel(model) {
    if (/^[a-zA-Z]/.test(model)) {
        model = model.charAt(0).toUpperCase() + model.slice(1).toLowerCase()
    }

    const lastChar = model.slice(-1)
    if (!isNaN(lastChar)) {
        model = model.slice(0, -1) + ' ' + lastChar
    }
    return model
}