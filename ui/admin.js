
window.addEventListener("message", function (event) {
    switch (event.data.action) {
        case "conce_admin":
            if (event.data.display === false) {
                $(".container-admin").fadeOut(100)
            } else {
                $(".container-admin").fadeIn(100)
                StartAdminConce()
            }
            break
    }
})



function Notify(data) {
    fetch(`https://${GetParentResourceName()}/conce_admin`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json charset=UTF-8' },
        body: JSON.stringify(data)
    }).then(retval => retval.json()).then(retval => {

    })
}

function LuaPost(action, data) {
    if (action && data) {
        fetch(`https://${GetParentResourceName()}/${action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json charset=UTF-8' },
            body: JSON.stringify(data)
        }).then(retval => retval.json()).then(retval => { })
    }
}

function LuaCallBack(cb, action, data) {
    if (action && data) {
        fetch(`https://${GetParentResourceName()}/${action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json charset=UTF-8' },
            body: JSON.stringify(data)
        }).then(retval => retval.json()).then(retval => {
            if (retval) {
                cb(retval)
            }

        })
    }
}




function StartAdminConce() {
    let allVehicles = []
    let allCategories = []
    const debounceDelay = 50
    const containerCartaVehiculo = document.querySelector('.container-carta-vehiculo')
    const containeCartaCategoria = document.querySelector('.container-carta-categoria')
    const CrearBotonVehiculo = document.querySelector('.crear-veh')
    const CrearCateBoton = document.querySelector('.crear-cat')
    const searchInput = document.getElementById('search')



    LuaCallBack(function (retval) {
        if (retval && retval.vehiculos) {
            allVehicles = retval.vehiculos
            allCategories = retval.categorias
            renderVehicles(allVehicles, allCategories)
        }
    }, 'conce_admin', { action: 'get_vehicles' })

    function debounce(func, delay) {
        let timeoutId
        return function () {
            const context = this
            const args = arguments
            clearTimeout(timeoutId)
            timeoutId = setTimeout(function () {
                func.apply(context, args)
            }, delay)
        }
    }

    function filterVehiclesAndRender(searchTerm) {
        const filteredVehicles = allVehicles.filter(vehicle => {
            const label = vehicle.name.toLowerCase()
            const model = vehicle.model.toLowerCase()
            return label.includes(searchTerm) || model.includes(searchTerm)
        })

        renderVehicles(filteredVehicles, allCategories)
    }


    const debouncedFilter = debounce(filterVehiclesAndRender, debounceDelay)

    searchInput.addEventListener('input', function () {
        const searchTerm = this.value.toLowerCase()
        debouncedFilter(searchTerm)
    })

    function createVehicleCard(data, allCategories) {
        const cartaVehiculo = document.createElement('div')
        cartaVehiculo.className = 'carta-vehiculo'

        cartaVehiculo.dataset.vehicleName = data.name
        cartaVehiculo.dataset.vehicleModel = data.model
        cartaVehiculo.dataset.vehiclePrice = data.price
        cartaVehiculo.dataset.vehicleCategory = data.category

        const optionsHTML = allCategories.map(category => {
            return `<option value="${category.name}" ${data.category.toLowerCase() === category.name.toLowerCase() ? 'selected' : ''}>${category.label}</option>`
        }).join('')

        cartaVehiculo.innerHTML = CartaVehiculo(data, optionsHTML)

        return cartaVehiculo
    }


    function renderVehicles(vehicleList, allCategories) {
        containerCartaVehiculo.innerHTML = ''

        vehicleList.forEach(data => {
            const cartaVehiculo = createVehicleCard(data, allCategories)
            containerCartaVehiculo.appendChild(cartaVehiculo)
        })

        const selectElement = document.getElementById('cars')

        selectElement.innerHTML = ''
        containeCartaCategoria.innerHTML = ''

        allCategories.forEach(data => {

            const option = document.createElement('option')
            option.value = data.name
            option.textContent = data.label
            selectElement.appendChild(option)

            containeCartaCategoria.innerHTML += CartaCategoria(data.label, data.name)

        })

        document.querySelectorAll('.delete-cat').forEach(deleteCat => {
            if (!deleteCat.hasEventListener) {
                deleteCat.addEventListener('click', function () {
                    const categoryElement = this.parentElement
                    const Name = categoryElement.querySelector('.name-cat span').textContent
                    const Label = categoryElement.querySelector('.label-cat span').textContent

                    mostrarAlerta(`¿Deseas eliminar la categoria: ${Name}?`, (resultado) => {
                        if (resultado === true) {
                            LuaCallBack(function (retval) {
                                if (retval) {
                                    categoryElement.remove()
                                    LuaCallBack(function (retval) {
                                        if (retval && retval.vehiculos) {
                                            allVehicles = retval.vehiculos
                                            allCategories = retval.categorias
                                            renderVehicles(allVehicles, allCategories)
                                        }
                                    }, 'conce_admin', { action: 'get_vehicles' })
                                }
                            }, 'conce_admin', { action: 'categoria', db: 'delete', value: { label: Label, name: Name } })
                        }
                    })
                })
                deleteCat.hasEventListener = true
            }
        })

    }



    if (!CrearBotonVehiculo.hasEventListener) {
        CrearBotonVehiculo.addEventListener('click', function (event) {
            event.preventDefault()
            const labelVehValue = document.querySelector('.label-veh-new input')
            const nameVehValue = document.querySelector('.name-veh-new input')
            const priceVehValue = document.querySelector('.price-veh-new input')
            const cateVehValue = document.querySelector('.cate-veh-new select')
            LuaCallBack(function (retval) {
                if (retval) {
                    if (labelVehValue.value.length > 3 && nameVehValue.value.length > 3) {
                        labelVehValue.value = ''
                        nameVehValue.value = ''
                        priceVehValue.value = ''
                        cateVehValue.value = ''
                        LuaCallBack(function (retval) {
                            if (retval && retval.vehiculos) {
                                allVehicles = retval.vehiculos
                                allCategories = retval.categorias
                                renderVehicles(allVehicles, allCategories)
                            }
                        }, 'conce_admin', { action: 'get_vehicles' })
                    } else {
                        Notify({ action: 'noti', text: 'Los valores deben tener más de 3 letras cada uno' })
                    }
                }
            }, 'conce_admin', { action: 'vehiculo', db: 'add', value: { label: labelVehValue.value, name: nameVehValue.value, price: priceVehValue.value, categoria: cateVehValue.value } })




        })
        CrearBotonVehiculo.hasEventListener = true
    }
    if (!containerCartaVehiculo.hasEventListener) {
        containerCartaVehiculo.addEventListener('click', function (event) {
            const target = event.target
            const cartaVehiculo = target.closest('.carta-vehiculo')

            if (cartaVehiculo) {
                const vehicleName = cartaVehiculo.dataset.vehicleName
                const vehicleModel = cartaVehiculo.dataset.vehicleModel
                const vehiclePrice = cartaVehiculo.dataset.vehiclePrice
                const vehicleCategory = cartaVehiculo.dataset.vehicleCategory

                if (target.classList.contains('delete-veh')) {
                    mostrarAlerta(`¿Deseas eliminar el vehículo: ${vehicleName}?`, (resultado) => {
                        if (resultado === true) {
                            LuaCallBack(function (retval) {
                                if (retval) {
                                    LuaCallBack(function (retval) {
                                        if (retval && retval.vehiculos) {
                                            allVehicles = retval.vehiculos
                                            allCategories = retval.categorias
                                            renderVehicles(allVehicles, allCategories)
                                        }
                                    }, 'conce_admin', { action: 'get_vehicles' })
                                    cartaVehiculo.remove()
                                }
                            }, 'conce_admin', { action: 'vehiculo', db: 'delete', value: { label: vehicleName, name: vehicleModel, price: vehiclePrice, categoria: vehicleCategory } })
                        }
                    })
                } else if (target.classList.contains('update-veh')) {
                    const nuevoPrecio = cartaVehiculo.querySelector('.price-veh-input input').value
                    const nuevaCategoria = cartaVehiculo.querySelector('.nueva-categoria').value

                    mostrarAlerta(`¿Quieres actualizar el vehículo?: ${vehicleName}?`, (resultado) => {
                        if (resultado === true) {
                            LuaCallBack(function (retval) {
                                if (retval) {
                                    LuaCallBack(function (retval) {
                                        if (retval && retval.vehiculos) {
                                            allVehicles = retval.vehiculos
                                            allCategories = retval.categorias
                                            renderVehicles(allVehicles, allCategories)
                                        }
                                    }, 'conce_admin', { action: 'get_vehicles' })
                                }
                            }, 'conce_admin', { action: 'vehiculo', db: 'update', value: { label: vehicleName, price: vehiclePrice, name: vehicleModel, category: vehicleCategory, neWprice: nuevoPrecio, neWcategoria: nuevaCategoria } })
                        }
                    })

                } else if (target.classList.contains('spawn-veh')) {
                }
            }
        })

        containerCartaVehiculo.hasEventListener = true
    }

    if (!CrearCateBoton.hasEventListener) {
        CrearCateBoton.addEventListener('click', function () {
            const labelCatValue = document.querySelector('.label-cat-new input')
            const nameCatValue = document.querySelector('.name-cat-new input')

            if (labelCatValue.value.length > 3 && nameCatValue.value.length > 3) {
                LuaCallBack(function (retval) {
                    if (retval) {
                        let newCategoryHTML = CartaCategoria(labelCatValue.value, nameCatValue.value)

                        containeCartaCategoria.insertAdjacentHTML('afterbegin', newCategoryHTML)

                        labelCatValue.value = ''
                        nameCatValue.value = ''
                        const newDeleteCat = document.querySelector('.container-carta-categoria .delete-cat')
                        LuaCallBack(function (retval) {
                            if (retval && retval.vehiculos) {
                                allVehicles = retval.vehiculos
                                allCategories = retval.categorias
                                renderVehicles(allVehicles, allCategories)
                            }
                        }, 'conce_admin', { action: 'get_vehicles' })
                        newDeleteCat.addEventListener('click', function () {
                            const categoryElement = this.parentElement
                            const Name = categoryElement.querySelector('.name-cat span').textContent
                            const Label = categoryElement.querySelector('.label-cat span').textContent

                            mostrarAlerta(`¿Deseas eliminar la categoría: ${Name}?`, (resultado) => {
                                if (resultado === true) {
                                    LuaCallBack(function (retval) {
                                        if (retval) {
                                            LuaCallBack(function (retval) {
                                                if (retval && retval.vehiculos) {
                                                    allVehicles = retval.vehiculos
                                                    allCategories = retval.categorias
                                                    renderVehicles(allVehicles, allCategories)
                                                }
                                            }, 'conce_admin', { action: 'get_vehicles' })
                                            categoryElement.remove()
                                        }
                                    }, 'conce_admin', { action: 'categoria', db: 'delete', value: { label: Label, name: Name } })
                                }
                            })
                        })
                    }

                }, 'conce_admin', { action: 'categoria', db: 'add', value: { label: labelCatValue.value, name: nameCatValue.value } })
            } else {
                Notify({ action: 'noti', text: 'Los valores deben tener más de 3 letras cada uno' })
            }
        })
        CrearCateBoton.hasEventListener = true
    }

    document.querySelector('.boton-cerrar').addEventListener('click', function () {
        LuaPost('conce_admin', { action: 'close' })
    })

    document.querySelector('.boton-categorias').addEventListener('click', function () {
        showLoading()
        $(".content-vehiculos").fadeOut(500, function () {
            hideLoading()
            $(".content-categorias").fadeIn(500)
        })
    })

    document.querySelector('.boton-vehiculos').addEventListener('click', function () {
        showLoading()
        $(".content-categorias").fadeOut(500, function () {
            hideLoading()
            $(".content-vehiculos").fadeIn(1000)
        })
    })

    function showLoading() {
        $(".content-load").fadeIn(300)
    }

    function hideLoading() {
        $(".content-load").fadeOut(300)
    }
}


const CartaVehiculo = function (data, optionsHTML) {
    return `
    <div class="sepe-carta-veh">
        <div class="label-veh">Label <span id="label-veh">${data.name}</span></div>
        <div class="name-veh">Model <span id="name-veh">${data.model}</span></div>
    </div>
    <div class="sepe-carta-veh">
        <div class="price-lab-veh">Precio <span id="price-lab-veh">${data.price} $</span></div>
        <div class="catego-lab-veh">Categoria <span id="catego-lab-veh">${data.category}</span></div>
    </div>
    <div class="sepe-carta-veh">
        <div class="price-veh-input"><input type="number" name="" id="" placeholder="Nuevo Precio"></div>
        <div class="price-veh-option">
            <select class="nueva-categoria" id="car-${data.name}">
                ${optionsHTML}
            </select>
        </div>
    </div>
    <div class="sepe-carta-veh">
        <div class="delete-veh boton"><i class="fa-solid fa-trash-can"></i> Eliminar</div>
        <div class="update-veh boton"><i class="fa-solid fa-save"></i> Guardar</div>
        <div class="spawn-veh boton"><i class="fa-solid fa-car-on"></i>Spawn</div>
    </div`
}

const CartaCategoria = function (labelCatValue, nameCatValue) {
    return `
    <div class="carta-categoria">
        <div class="label-cat">Label: <span id="label-cat">${labelCatValue}</span></div>
        <div class="name-cat">Name: <span id="name-cat">${nameCatValue}</span></div>
        <div class="delete-cat"><i class="fa-solid fa-trash-can"></i></div>
    </div>`
}



var alertaVisible = false

function mostrarAlerta(texto, cb) {

    if (alertaVisible) { return }

    var containerAlerta = document.getElementById('containerAlerta')
    var alertaTexto = document.getElementById('alertaTexto')
    var botonCancelar = document.getElementById('botonCancelar')
    var botonConfirmar = document.getElementById('botonConfirmar')

    alertaTexto.textContent = texto
    containerAlerta.style.display = 'flex'
    alertaVisible = true

    function manejarCancelar() {
        containerAlerta.style.display = 'none'
        alertaVisible = false
        if (cb) { cb(false) }
        botonCancelar.removeEventListener('click', manejarCancelar)
        botonConfirmar.removeEventListener('click', manejarConfirmar)
    }

    function manejarConfirmar() {
        containerAlerta.style.display = 'none'
        alertaVisible = false
        if (cb) { cb(true) }
        botonCancelar.removeEventListener('click', manejarCancelar)
        botonConfirmar.removeEventListener('click', manejarConfirmar)
    }

    botonCancelar.addEventListener('click', manejarCancelar)
    botonConfirmar.addEventListener('click', manejarConfirmar)
}


