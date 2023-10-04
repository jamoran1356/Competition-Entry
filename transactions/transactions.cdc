// Importar los contratos TopShot y myNBAtsBM
import TopShot from 0x877931736ee77cff
import myNBAtsBM from 0x6c0860268db732a7

// Definir la transacción con un parámetro que sea el array de id de los momentos que quieres quemar
transaction (tokenIDs: [UInt64]) {

  // Definir el bloque prepare con el autorizador de la transacción, que debe ser el propietario de los momentos
  prepare (signer: AuthAccount) {
    // Obtener una referencia a la colección del propietario usando su capacidad pública
    let ownerCollection = signer.getCapability<&{TopShot.CollectionPublic}>(/public/MomentCollection)
      .borrow()
      ?? panic("No se pudo obtener la referencia a la colección del propietario")

    // Llamar a la función selectMoments del contrato myNBAtsBM y pasarle la referencia a la colección y el array de id
    // Esto devolverá una referencia a un recurso toburn que contiene los id de los momentos seleccionados
    let toBurnRef <- myNBAtsBM.selectMoments(ownerCollection: ownerCollection, tokenIDs: tokenIDs)

    // Guardar la referencia al recurso toburn en el almacenamiento del propietario
    signer.save(<-toBurnRef, to: /storage/toBurn)
  }

  // Definir el bloque execute con la lógica principal de la transacción
  execute {
    // Acceder al almacenamiento del propietario y obtener una referencia al recurso toburn
    let toBurnRef = signer.borrow<&myNBAtsBM.toburn>(from: /storage/toBurn)
      ?? panic("No se pudo obtener la referencia al recurso toburn")

    // Obtener una referencia a la colección del propietario usando su capacidad pública
    let ownerCollection = signer.getCapability<&{TopShot.CollectionPublic}>(/public/MomentCollection)
      .borrow()
      ?? panic("No se pudo obtener la referencia a la colección del propietario")

    // Llamar a la función burnMoments del recurso toburn y pasarle la referencia a la colección
    // Esto quemará los momentos y emitirá un evento por cada uno
    toBurnRef.burnMoments(ownerCollection: ownerCollection)
  }
}
