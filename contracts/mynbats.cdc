import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken from 0x9a0766d93b6608b7
import MetadataViews from 0x6c0860268db732a7
import DapperUtilityCoin from 0x82ec283f88a62e65
import TopShot from 0x877931736ee77cff



pub contract myNBAtsBM {
    //emit events    
    pub event PlayCreated(id: UInt32, metadata: {String:String})
    pub event MomentMinted(momentID: UInt64, playID: UInt32, setID: UInt32, serialNumber: UInt32, subeditionID: UInt32)
    pub event MomentDestroyed(id: UInt64)
    //var

    // definimos el recurso toburn
    pub resource toburn {
        // declaramos el diccionario de id como una variable pública
        pub var tokenIDs: {UInt64: UInt64}

        // definimos el inicializador del recurso
        init(tokenIDs: {UInt64: UInt64}) {
            // asignamos el valor del parámetro al diccionario de id
            self.tokenIDs = tokenIDs
        }

        // definimos la función selectMoments
        pub fun selectMoments(ownerCollection: Capability<&TopShot.Collection>, tokenIDs: [UInt64]): @toburn {
            // verificamos que la colección del usuario sea válida
            pre {
                ownerCollection.check(): "La colección del usuario no es válida"
            }

            // creamos una instancia del recurso toburn con el diccionario de id
            let toBurn <- create toburn(tokenIDs: {})

            // iteramos sobre el array de id
            for tokenID in tokenIDs {
                // verificamos que el momento exista en la colección del usuario
                assert(
                    ownerCollection.borrow()!.borrowMoment(id: tokenID) != nil,
                    message: "El momento con el ID ".concat(tokenID.toString()).concat(" no existe en la colección del usuario")
                )
                // agregamos el id al diccionario de toBurn usando su clave
                toBurn.tokenIDs[tokenID] = tokenID 
            }

            // devolvemos la referencia al recurso toburn
            return <-toBurn // usamos el operador de movimiento para devolver el recurso
        }

        // definimos la función burnMoments
        pub fun burnMoments(ownerCollection: Capability<&TopShot.Collection>): Void {
            // verificamos que la colección del usuario sea válida
            pre {
                ownerCollection.check(): "La colección del usuario no es válida"
            }

            // iteramos sobre el diccionario de id
            for tokenID in self.tokenIDs.keys {
                // retiramos el momento de la colección del usuario usando su id
                let moment <- ownerCollection.borrow()!.withdraw(withdrawID: tokenID)
                // destruimos el momento usando el operador de desenlace
                destroy moment
                // emitimos un evento para indicar que el momento fue destruido
                emit MomentDestroyed(id: tokenID)
            }
        }

    }

    init(){
        log("Hola desde Venezuela");
    }
    
    // definimos la función createNewMoment
      // En esta funcion se debe incluir la funcion de minteo del contrato de TopShot, 
      // la misma no compila, por lo que tendria que realizar la actualizacion del 
      // contrato para ser incluida.
      // También es posible desarrollar un proyecto independiente en donde se quemen
      // momentos para crear nuevos NFTs, cada una de las ideas busca contribuir 
      // en la disminución de la cantidad de momentos que tienen un alto impacto
      // en los inversores y coleccionistas 
    
    // pub fun createNewMoment(
    //     toBurnRef: &toburn, 
    //     ownerCollection: Capability<&TopShot.Collection>, 
    //     player: String, // 
    //     description: String, 
    //     price: UFix64 // el parámetro es el precio del nuevo momento
    // ): @TopShot.NFT? {
    //     // obtenemos el id del jugador usando su nombre
    //     let playerID = TopShot.getPlayerID(player) ?? 0
    //     if playerID == 0 { return nil }

    //     // quemamos los momentos almacenados en el recurso toburn
    //     toBurnRef.burnMoments(ownerCollection: ownerCollection)

    //     // creamos un nuevo play con los datos del nuevo momento
    //     let play = TopShot.Play(
    //         player: player,
    //         description: description,
    //         price: price
    //     )

    //     // creamos un nuevo momento con el play, el set, el serial number y el subedition id
    //     // creamos un nuevo momento con el play, el set, el serial number y el subedition id
    // let newMoment <- TopShot.mintMomentWithRarity(
    //     playID: playerID,
    //     setID: UInt32(TopShot.nextSetID),
    //     serialNumber: TopShot.getNextSerialNumber(setID: UInt32(TopShot.nextSetID)),
    //     subeditionID: 0,
    //     price: price,
    //     rarity: 1 // puedes cambiar este valor según la rareza que quieras
    // )

    // // emitimos el evento NewMomentMinted con los datos del nuevo momento
    // emit NewMomentMinted(
    //     momentID: newMoment.id,
    //     playID: playerID,
    //     setID: UInt32(TopShot.nextSetID),
    //     serialNumber: TopShot.getNextSerialNumber(setID: UInt32(TopShot.nextSetID)),
    //     subeditionID: 0,
    //     rarity: 1 // debes usar el mismo valor que usaste para crear el momento
    // )

    // // depositamos el nuevo momento en la colección del usuario
    // ownerCollection.borrow()!.deposit(token: <-newMoment)

    // // devolvemos el nuevo momento
    // return <-newMoment

    // }
    
    
}
