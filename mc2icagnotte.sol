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
        uint128 id;
        uint CagnotteID;
        address sender;
        uint montant;
        string nom;
        string mot;
    }
    
    event CreationCagnotte(uint ID, string nom, uint montant, uint nbreContrib, bool statut);
    event ContributionCagnotte (uint128 ContribId, uint IDCagnotte, uint montant, string nom, string mot);
    
    //Get des cagnottes par leur ID
    mapping(uint => Cagnotte) public getCagnotteByID;
    //Get des contributions par leur ID
	mapping(uint => Contribution) public getContributionByID;
    //Get des ID cagnottes par utilisateur
    mapping(address => uint[]) public getIDCagnotteByOwner;
	//Get des ID contributions par utilisateur
    mapping(address => uint[]) public getIDContribByOwner;
    
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
        getIDCagnotteByOwner[msg.sender].push(idCagnotte);
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
		for (uint i = 0; i < cagnottes.length ; i++) {
			if (cagnottes[i].id == _id) {
				cagnottes[i].statut = false;
				getCagnotteByID[_id].statut = false;
			}
		}
    }

    /// @notice Contribue à une cagnotte, en laissant un nom et un mot avec le montant
    /// @param _id L'ID de la cagnotte
    /// @param _nom Le nom du contributeur
    /// @param _mot Le mot laissé par le contributeur
    /// @return bool Succès de la contribution
    function ContribuerCagnotte(uint _id, string _nom, string _mot) payable public returns (bool success) {
        require (getCagnotteByID[_id].statut == true, "La cagnotte est fermée, vous ne pouvez plus y contribuer");
        require (msg.value > 0, "Vous ne pouvez pas contribuer à hauteur de 0 mc2icoins");
        
        //ID de la contrib = Hachage de l'adresse de l'expéditeur, du numéro de la cagnotte, du nom et mot laissé
        uint128 ContribId = uint128(keccak256(msg.sender, idCagnotte, _nom, _mot));
        
        //On l'insère dans le tableau des contributions
        Contribution memory _contribution = Contribution(ContribId, _id, msg.sender, msg.value, _nom, _mot);
        contributions.push(_contribution);
        
        //On l'insère dans le mapping
        getContributionByID[ContribId] = _contribution;
		getIDContribByOwner[msg.sender].push(_contribution.id);
        
		for (uint i = 0; i < cagnottes.length ; i++) {
			if (cagnottes[i].id == _id) {
				//On met à jour les montants / nombre de contributions dans le tableau / mapping				
				cagnottes[i].montant += msg.value;
				cagnottes[i].nbreContributions += 1;
		        getCagnotteByID[_id].montant += msg.value;
				getCagnotteByID[_id].nbreContributions += 1;
				
				//On émet l'event
				emit ContributionCagnotte(ContribId, _id, msg.value, _nom, _mot);
				return (true);
			}
		}
		
		return(false);
    }

    /// @notice Permet d'obtenir chaque contribution relatives à une cagnotte
    /// @dev Ne retourne pour l'instant que des tableaux d'adresses et d'int, une solution pour les noms et mots est en cours d'investigation
    /// @param _id L'ID de la cagnotte
    /// @return uint128[] Tableau des ID des contributions
    /// @return address[] Tableau des adresses des contributeurs
    /// @return uint[] Tableau des montants des contributions
    function getContributionsByCagnotte(uint _id) public view returns (uint128[], address[], uint[]) {
        //On réserve trois tableaux et on fixe leur taille avec le nombre de contributions de la cagnotte
		uint128[] memory _idContribs = new uint128[](getCagnotteByID[_id].nbreContributions);
		address[] memory _contribs = new address[](getCagnotteByID[_id].nbreContributions);
        uint[] memory _montants = new uint[](getCagnotteByID[_id].nbreContributions);
        uint counter = 0;
		//On itère dans le tableau des contributions, à la recherhe des contributions liées à la cagnotte
        for (uint i = 0 ; i < contributions.length ; i++) {
			//Dès qu'on en trouve une
            if (contributions[i].CagnotteID == _id) {
				//On charge ses paramètres dans les trois tableaux temporaires
                Contribution storage contrib = contributions[i];
                _idContribs[counter] = contrib.id;
                _contribs[counter] = contrib.sender;
                _montants[counter] = contrib.montant;
                counter++;
            }
        }
        return(_idContribs, _contribs, _montants);
    }
}