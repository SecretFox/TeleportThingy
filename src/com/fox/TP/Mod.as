import GUI.RegionTeleport.PlayfieldEntry;
import com.GameInterface.DistributedValue;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.Utils;
import mx.utils.Delegate;
/**
 * ...
 * @author fox
 */
class com.fox.TP.Mod {
	private var RegionDval:DistributedValue;
	public static function main(swfRoot:MovieClip){
		var s_app = new Mod();
		swfRoot.onLoad = function(){s_app.Load()};
		swfRoot.onUnload = function(){s_app.Unload()};
	}
	public function Mod() { }
	public function Load() {
		RegionDval = DistributedValue.Create("regionTeleport_window");
		RegionDval.SignalChanged.Connect(Reorder, this);
		Reorder(RegionDval);
	}
	public function Unload() {
		RegionDval.SignalChanged.Disconnect(Reorder, this);
	}
	private function Createlist(headerNode:LoreNode){
		var scrollList:MovieClip = _root.regionteleport.m_Window.m_Content.m_ScrollPanel;
		scrollList.m_PlayfieldEntries = new Array();
		scrollList.m_ListContent = scrollList.createEmptyMovieClip("m_ListContent", scrollList.getNextHighestDepth());
		var node = headerNode.m_Children[headerNode.m_Children.length - 1];
		var playfieldEntry:PlayfieldEntry = PlayfieldEntry(scrollList.m_ListContent.attachMovie("PlayfieldEntry", "PlayfieldEntry_" + node.m_Id, scrollList.m_ListContent.getNextHighestDepth()));
		playfieldEntry.SetData(node, 0);
		playfieldEntry.SignalEntrySizeChanged.Connect(scrollList.LayoutEntries, scrollList);
		playfieldEntry.SignalEntryFocused.Connect(scrollList.SlotEntryFocused, scrollList);
		playfieldEntry.SignalEntryActivated.Connect(scrollList.SlotEntryActivated, scrollList);
		scrollList.m_PlayfieldEntries.push(playfieldEntry);
		for (var i:Number = 0; i < headerNode.m_Children.length-1; i++)
		{
			if (Utils.GetGameTweak("HideTeleport_" + headerNode.m_Children[i].m_Id) == 0)
			{
				playfieldEntry = PlayfieldEntry(scrollList.m_ListContent.attachMovie("PlayfieldEntry", "PlayfieldEntry_" + headerNode.m_Children[i].m_Id, scrollList.m_ListContent.getNextHighestDepth()));
				playfieldEntry.SetData(headerNode.m_Children[i], 0);
				playfieldEntry.SignalEntrySizeChanged.Connect(scrollList.LayoutEntries, scrollList);
				playfieldEntry.SignalEntryFocused.Connect(scrollList.SlotEntryFocused, scrollList);
				playfieldEntry.SignalEntryActivated.Connect(scrollList.SlotEntryActivated, scrollList);
				scrollList.m_PlayfieldEntries.push(playfieldEntry);
			}
		}
		scrollList.CreateScrollBar();
		for (var i:Number = 0; i < scrollList.m_PlayfieldEntries.length; i++){
			scrollList.m_PlayfieldEntries[i].Expand();
		}
	}
	private function Reorder(dv:DistributedValue){
		if (dv.GetValue()){
			var scrollList:MovieClip = _root.regionteleport.m_Window.m_Content.m_ScrollPanel;
			if (!scrollList){
				setTimeout(Delegate.create(this, Reorder), 100, dv);
			}else{
				scrollList["CreateContent"] = Delegate.create(this, Createlist);
				scrollList["SetData"](Lore.GetTeleportTree());
			}
		}
	}
	
}