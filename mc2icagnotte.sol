pragma solidity ^0.4.23;


/// @title Smart-Contract de gestion des cagnottes des consultants mc²i
/// @author Mathias EDOUIN
contract mc2iCagnotte {

    struct Cagnotte {
        uint id;
        address owner;
        string nom;
        uint montant;
        uint nbreContributions;
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
    
    event CreationCagnotte(uint ID, string nom, uint montant, uint nbreContrib, bool statut);
    event ContributionCagnotte(uint IDCagnotte, uint montant, string nom, string mot);
    
    //On met le mapping en public les fonctions set/get
    mapping(uint => Cagnotte) public getCagnotteByID;
    
    
    Cagnotte[] cagnottes;
    Contribution[] contributions;
    
    //Variable globale d'ID de cagnottes
    uint idCagnotte = 1;

    /// @notice Crée la cagnotte avec seulement un nom
    /// @param _nom Le nom de la cagnotte
    function CreerCagnotte(string _nom) public {
        Cagnotte memory _cagnotte = Cagnotte(idCagnotte, msg.sender, _nom, 0, 0, now, true);
        //On met la cagnotte dans le tableau global
        cagnottes.push(_cagnotte);
        //On pousse la cagnotte dans le mapping
        getCagnotteByID[idCagnotte] = _cagnotte;
        //On envoie l'event pour le front
        emit CreationCagnotte(idCagnotte, _nom, 0, 0, true);
        //On incrémente la variable pour la cagnotte suivante
        idCagnotte++;
    }

    /// @notice Retire le montant d'une cagnotte dont on est le propriétaire, entraînant sa fermeture
    /// @param _id L'ID de la cagnotte
    function RetirerCagnotte(uint _id) public {
        //La personne qui doit retirer la cagnotte doit être son propriétaire
        require (getCagnotteByID[_id].owner == msg.sender, "Vous n'êtes pas le propriétaire de la cagnotte");
        //On transfert le montant de la cagnotte à son propriétaire
		msg.sender.transfer(getCagnotteByID[_id].montant);
		//On ferme la cagnotte
        getCagnotteByID[_id].statut = false;
        
    }

    /// @notice Contribue à une cagnotte, en laissant un nom et un mot avec le montant
    /// @param _id L'ID de la cagnotte
    /// @param _nom Le nom du contributeur
    /// @param _mot Le mot laissé par le contributeur
    /// @return bool Succès de la contribution
    function ContribuerCagnotte(uint _id, string _nom, string _mot) payable public returns (bool success) {
        require (getCagnotteByID[_id].statut == true, "La cagnotte est fermée, vous ne pouvez plus y contribuer");
        require (msg.value > 0, "Vous ne pouvez pas contribuer à hauteur de 0 mc2icoins");
        Contribution memory _contribution = Contribution(_id, msg.sender, msg.value, _nom, _mot);
        contributions.push(_contribution);
        getCagnotteByID[_id].montant += msg.value;
        getCagnotteByID[_id].nbreContributions += 1;
        emit ContributionCagnotte(_id, msg.value, _nom, _mot);
        return (true);
    }

    /// @notice Permet d'obtenir chaque contribution relatives à une cagnotte
    /// @dev Ne retourne pour l'instant que des tableaux d'adresses et d'int, une solution pour les noms et mots est en cours d'investigation
    /// @param _id L'ID de la cagnotte
    /// @return address[] Tableau des adresses des contributeurs
    /// @return uint[] Tableau des montants des contributions
    function getContributionsByCagnotte(uint _id) public view returns (address[], uint[]) {
        //On réserve deux tableaux et on fixe leur taille avec le nombre de contributions de la cagnotte
		address[] memory _contribs = new address[](getCagnotteByID[_id].nbreContributions);
        uint[] memory _montants = new uint[](getCagnotteByID[_id].nbreContributions);
        uint counter = 0;
		//On itère dans le tableau des contributions, à la recherhe des contributions liées à la cagnotte
        for (uint i = 0 ; i < contributions.length ; i++) {
			//Dès qu'on en trouve une
            if (contributions[i].CagnotteID == _id) {
				//On charge ses paramètres dans les deux tableaux temporaires
                Contribution storage contrib = contributions[i];
                _contribs[counter] = contrib.sender;
                _montants[counter] = contrib.montant;
                counter++;
            }
        }
        return(_contribs, _montants);
    }
}