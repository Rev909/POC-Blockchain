pragma solidity ^0.4.23;
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
        uint CagnotteID;
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
    function RetirerCagnotte(uint _id) public {
        require (IdToCagnotte[_id].owner == msg.sender, "Vous n'êtes pas le propriétaire de la cagnotte");
        for (uint i = 0 ; i <= cagnottes.length ; i++) {
            if (cagnottes[i].id == _id) {
                msg.sender.transfer(cagnottes[i].montant);
                cagnottes[i].statut = false;
            }
        }
        
    }

    /// Contribuer à une cagnotte
    function ContribuerCagnotte(uint _id, string _nom, string _mot) payable public returns (string) {
        uint valeurContrib = msg.value * 1 ether;
        require (IdToCagnotte[_id].statut == true, "La cagnotte est fermée, vous ne pouvez plus y contribuer");
        require(msg.sender.balance > msg.value, "Vous n'avez pas assez d'ethers pour contribuer à la cagnotte");
        Contribution memory _contribution = Contribution(_id, msg.sender, valeurContrib, _nom, _mot);
        contributions.push(_contribution);
        for (uint j = 0 ; j <= cagnottes.length ; j++) {
            if (cagnottes[j].id == _id) {
                cagnottes[j].montant += msg.value;
                return ("Merci de votre contribution !");
            }
        }
    }

    /// Afficher une cagnotte
    function getCagnotte(uint _id) public view returns (bool found, string error, address owner, string nom, uint montant, bool statut) {
        for (uint i = 0 ; i <= cagnottes.length ; i++) {
            if (cagnottes[i].id == _id) {
                return (true,"", cagnottes[i].owner, cagnottes[i].nom, cagnottes[i].montant, cagnottes[i].statut);
            }
        }
        return (false, "Cagnotte non trouvée",0x0, "", 0,false);
    }

    /// Afficher les contributions d'une cagnotte
    function getContributionsCagnotte(uint _id) public view returns (address[10], uint[10], string[10], string[10]) {
        address[10] memory _contributeurs;
        uint[10] memory _montants;
        string[10] memory _noms;
        string[10] memory _mots;
        uint counter = 0;
        for (uint i = 0 ; i <= contributions.length ; i++) {
            if (_id == contributions[i].CagnotteID) {
                _contributeurs[counter] = contributions[i].sender;
                _montants[counter] = contributions[i].montant;
                _noms[counter] = contributions[i].nom;
                _mots[counter] = contributions[i].mot;
                counter++;
            }
        }
        return(_contributeurs, _montants, _noms, _mots);
    }
}