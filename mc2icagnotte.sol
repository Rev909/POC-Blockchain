pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;

contract mc2iCagnotte {

    struct Cagnotte {
        uint id;
        address owner;
        string nom;
        uint montant;
        uint date;
        bool statut;
    }
    
    struct Contribution {
        address sender;
        uint montant;
        string nom;
        string mot;
    }
    
    mapping(uint => Cagnotte) IdToCagnotte;
    Cagnotte[] cagnottes;
    Contribution[] contributions;
    uint idCagnotte = 1;

    /// Créer une nouvelle cagnotte initialisée à 0
    function CreerCagnotte(string _nom) public {
        Cagnotte memory _cagnotte = Cagnotte(idCagnotte, msg.sender, _nom, 0, now, true);
        cagnottes.push(_cagnotte);
        IdToCagnotte[idCagnotte] = _cagnotte;
        idCagnotte++;
    }

    /// Retirer l'argent d'une cagnotte
    function RetirerCagnotte(uint _id) external {
        require (IdToCagnotte[_id].owner == msg.sender, "Vous n'êtes pas le propriétaire de la cagnotte");
        msg.sender.transfer(IdToCagnotte[_id].montant);
        IdToCagnotte[_id].statut = false;
        
    }

    /// Contribuer à une cagnotte
    function delegate(address to) public {

    }

    /// Afficher une cagnotte
    function getCagnotte(uint _id) public view returns (bool found, string error, string nom, uint montant, bool statut) {
        for (uint i = 0 ; i <= cagnottes.length ; i++) {
            if (cagnottes[i].id == _id) {
                Cagnotte storage _cagnotte = cagnottes[i];
                return (true,"", _cagnotte.nom, _cagnotte.montant, _cagnotte.statut);
            }
        }
        
        return (false, "Cagnotte non trouvée", "", 0,false);
    }

    /// Afficher les contributions d'une cagnotte
    function winningProposal() public constant returns (uint8 _winningProposal) {

    }
}