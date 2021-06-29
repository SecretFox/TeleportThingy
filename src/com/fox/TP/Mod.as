import com.GameInterface.DistributedValue;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.Utils.Archive;
import mx.utils.Delegate;
/**
 * ...
 * @author fox
 */
class com.fox.TP.Mod {
	private var RegionDval:DistributedValue;
	private var FavArray:Array;
	private var HideArray:Array;
	private var favButton;
	private var expandButton;
	private var active:LoreNode;
	private var favNode:LoreNode;
	
	public static function main(swfRoot:MovieClip){
		var s_app = new Mod();
		swfRoot.OnModuleActivated = function(config){s_app.Activate(config)};
		swfRoot.OnModuleDeactivated = function(){return s_app.Deactivate()};
	}
	public function Mod() {
	}
	public function Activate(config:Archive) {
		FavArray = config.FindEntryArray("Favorite");
		if (!FavArray) FavArray = new Array();
		HideArray = config.FindEntryArray("Hide");
		if (!HideArray) HideArray = new Array();
		DrawMenu();
	}
	private function DrawMenu()
	{
		var ScrollPanel:MovieClip = _root.regionteleport.m_Window.m_Content.m_ScrollPanel;
		if (!ScrollPanel ){
			setTimeout(Delegate.create(this, DrawMenu), 100);
		}else{
			var content:MovieClip = _root.regionteleport.m_Window.m_Content;
			if (!favButton){
				favButton = content.attachMovie("ChromeButtonWhite", "m_Favorite", content.getNextHighestDepth(),
					{_y:content.m_TeleportButton._y+2, _x:content.m_TeleportButton._x - content.m_TeleportButton._width}
				);
				favButton.disableFocus = true;
				favButton.label = "Favorite";;
				favButton._width = 70;
				favButton._height = 20;
				favButton.addEventListener("click", this, "Favorite");
				favButton._visible = false;
			}
			if (!expandButton){
				expandButton = content.attachMovie("ChromeButtonWhite", "m_Expand", content.getNextHighestDepth(),
					{_y:content.m_TeleportButton._y+2, _x:content.m_TeleportButton._x + content.m_TeleportButton._width*2-70}
				);
				expandButton.disableFocus = true;
				expandButton.label = "Hide";
				expandButton._width = 70;
				expandButton._height = 20;
				expandButton.addEventListener("click", this, "Hide");
				expandButton._visible = false;
			}
			reDraw();
		}
	}
	public function Deactivate() {
		var config:Archive = new Archive();
		for (var i:Number = 0; i < FavArray.length; i++){
			config.AddEntry("Favorite",FavArray[i]);
		}
		for (var i:Number = 0; i < HideArray.length; i++){
			config.AddEntry("Hide",HideArray[i]);
		}
		return config
	}
	//Adds or deleted a favorite
	private function Favorite(){
		var found;
		for (var i in FavArray){
			if (FavArray[i] == active.m_Id){
				FavArray.splice(Number(i), 1);
				found = true;
				favButton.label = "Favorite";
				break
			}
		}
		if (!found){
			FavArray.push(active.m_Id);
			favButton.label = "Unfavorite";
		}
		reDraw();
		//Set selected entry
		_root.regionteleport.m_Window.m_Content.m_ScrollPanel["SlotEntryFocused"](active);
		//Expand zone that got added after redraw
		for (var i in _root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"]){
			if (active.m_Parent.m_Id == _root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"][i].m_Id){
				_root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"][i].Expand();
				break
			}
		}
	}
	private function Hide(){
		var found;
		for (var i in HideArray){
			if (HideArray[i] == active.m_Parent.m_Id){
				HideArray.splice(Number(i), 1);
				found = true;
				expandButton.label = "Collapse";
				break
			}
		}
		if (!found){
			HideArray.push(active.m_Parent.m_Id);
			expandButton.label = "Expand";
			for(var i in _root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"]){
				if (active.m_Parent.m_Id == _root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"][i].m_Id){
					_root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"][i].Contract();
					break
				}
			}
		}
		//SetExpand();
	}
	// creates copy of a lorenode
	private function CopyNode(org:LoreNode){
		var newnode = new LoreNode();
		for (var i in org){
			newnode[i] = org[i];
		}
		return newnode
	}
	//Finds lorenode with specified id from lorenode children
	private function FindAndCopy(org:LoreNode, id:Number){
		for (var zone in org.m_Children){
			for (var loc in org.m_Children[zone].m_Children){
				if (org.m_Children[zone].m_Children[loc].m_Id == id){
					return CopyNode(org.m_Children[zone].m_Children[loc]);
				}
			}
		}
	}
	// finds original tree, removes favourites and readds it
	private function CreateFakeTree(){
		var orgNode:LoreNode =  CopyNode(Lore.GetTeleportTree());
		// for some reason fav node stays in the original teleport tree (when it is next time retrieved),even if i CopyNode() it
		// have to manually remove it or they keep piling up
		for (var i in orgNode.m_Children){
			if (orgNode.m_Children[i].m_Id == 99999){
				orgNode.m_Children.splice(Number(i), 1);
			}
		}
		if(FavArray.length>0){
			favNode = CopyNode(orgNode.m_Children[0]);
			favNode.m_Children = new Array();
			favNode.m_Id = 99999;
			favNode.m_Name = "Favorites";
			for (var i:Number = 0; i < FavArray.length; i++){
				var copy:LoreNode = FindAndCopy(orgNode, FavArray[i])
				copy.m_Parent = favNode;
				favNode.m_Children.push(copy);
			}
			orgNode.m_Children.unshift(favNode);
		}
		return orgNode
	}
	/* 
	* Entry selected
	* Sets button texts and visibility
	* Stores selected node for button use
	*/ 
	private function SlotEntryFocused(lorenode:LoreNode){
		active = lorenode;
		favButton._visible = true;
		expandButton._visible = true;
		var found;
		for (var i in FavArray){
			if (FavArray[i] == active.m_Id){
				favButton.label = "Unfavorite";
				found = true;
				break
			}
		}
		if (!found){
			favButton.label = "Favorite";
		}
		found = undefined;
		for (var i in HideArray){
			if (HideArray[i] == active.m_Parent.m_Id){
				expandButton.label = "Expand";
				found = true;
				break
			}
		}
		if (!found){
			expandButton.label = "Collapse";
		}
	}
	private function reDraw(){
		var node:LoreNode = CreateFakeTree();
		_root.regionteleport.m_Window.m_Content.m_ScrollPanel.SetData(node);
		_root.regionteleport.m_Window.m_Content.m_ScrollPanel.SignalEntryFocused.Disconnect(SlotEntryFocused, this);
		_root.regionteleport.m_Window.m_Content.m_ScrollPanel.SignalEntryFocused.Connect(SlotEntryFocused, this);
		SetExpand(node);
	}
	// m_ScrollPanel.SetData Expands all zones
	// This function contracts users hidden zones
	private function SetExpand(){
		for (var i in _root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"]){
			for (var y in HideArray){
				if (HideArray[y] == _root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"][i].m_Id){
					_root.regionteleport.m_Window.m_Content.m_ScrollPanel["m_PlayfieldEntries"][i].Contract();
					break
				}
			}
		}
	}
}