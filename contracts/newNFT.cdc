import NonFungibleToken from 0x631e88ae7f1d7c20

// definimos un nuevo contrato que implementa el estándar de token no fungible (NFT) de Flow
pub contract NewNFT {

    // definimos el tipo NFT como una interfaz que extiende la interfaz NonFungibleToken.INFT
    pub resource interface NFT: NonFungibleToken.INFT {
        pub let serialNumber: UInt32
        pub let playID: UInt32
        pub let setID: UInt32
        pub let subeditionID: UInt32
        // agregamos otros campos que queramos, como price o rarity
        pub let price: UFix64
        pub let rarity: UInt8

        init(_serialNumber: UInt32, _playID: UInt32, _setID: UInt32, _subeditionID: UInt32, _price: UFix64, _rarity: UInt8){
            self.serialNumber = _serialNumber
            self.playID = _playID
            self.subeditionID = _subeditionID
            self.price = _price
            self.rarity = _rarity
        }

        destroy()

    }

    // definimos un recurso NFT que contiene los mismos campos que el recurso NFT del contrato TopShot
    // y que implementa la interfaz NFT
    pub resource NFT: NewNFT.NFT {
        pub let serialNumber: UInt32
        pub let playID: UInt32
        pub let setID: UInt32
        pub let subeditionID: UInt32
        // agregamos otros campos que queramos, como price o rarity
        pub let price: UFix64
        pub let rarity: UInt8

        // definimos el inicializador del recurso
        init(serialNumber: UInt32, playID: UInt32, setID: UInt32, subeditionID: UInt32, price: UFix64, rarity: UInt8) {
            self.serialNumber = serialNumber
            self.playID = playID
            self.setID = setID
            self.subeditionID = subeditionID
            self.price = price
            self.rarity = rarity
        }

        // implementamos la función getID para devolver el id del NFT, que puede ser el número de serie o una combinación de los otros campos
        pub fun getID(): UInt64 {
            return self.serialNumber as UInt64
        }
    }

    // definimos una función mintNFT que recibe como parámetros los datos necesarios para crear un nuevo NFT
    pub fun mintNFT(playID: UInt32, setID: UInt32, serialNumber: UInt32, subeditionID: UInt32, price: UFix64, rarity: UInt8): @NewNFT.NFT {
        // creamos un nuevo NFT con los datos y lo devolvemos como un recurso NFT
        return <-create NFT(serialNumber: serialNumber, playID: playID, setID: setID, subeditionID: subeditionID, price: price, rarity: rarity)
    }

    // definimos una colección Collection que implementa la interfaz NonFungibleToken.CollectionPublic
    pub resource Collection: NonFungibleToken.CollectionPublic {
        // declaramos el diccionario de NFTs como una variable pública usando el tipo NewNFT.NFT
        pub var ownedNFTs: @{UInt64: NewNFT.NFT}

        // definimos el inicializador del recurso
        init() {
            self.ownedNFTs <- {}
        }

        // definimos la función destroy que libera el diccionario de NFTs
        destroy() {
            destroy self.ownedNFTs
        }

        // implementamos la interfaz NonFungibleToken.CollectionPublic
        // usamos el tipo NewNFT.NFT para el parámetro token y el tipo de retorno
        pub fun deposit(token: @NewNFT.NFT) {
            let token <- token as! @NewNFT.NFT
            let id = token.getID()
            self.ownedNFTs[id] <-! token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // usamos el tipo NewNFT.NFT para el tipo de retorno
        pub fun borrowNFT(id: UInt64): &NewNFT.NFT {
            pre {
                self.ownedNFTs[id] != nil: "No NFT with this ID in the collection"
            }
            return &self.ownedNFTs[id]! as &NewNFT.NFT
        }

        // usamos el tipo NewNFT.NFT para el tipo de retorno
        pub fun withdraw(withdrawID: UInt64): @NewNFT.NFT {
            pre {
                self.ownedNFTs[withdrawID] != nil: "No NFT with this ID in the collection"
            }
            let token <- self.ownedNFTs.remove(key: withdrawID)! as! @NewNFT.NFT
            return <-token
        }
    }

    // definimos una función createEmptyCollection que crea una nueva colección vacía y la devuelve como un recurso Collection
    pub fun createEmptyCollection(): @Collection {
        return <-create Collection()
    }
}
