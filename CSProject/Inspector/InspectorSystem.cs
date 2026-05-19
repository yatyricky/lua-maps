using LuaWrapper;
using SFLib.Collections;

namespace Systems;

public class InspectorSystem : SystemBase
{
    private const int MaxHierarchyRows = 18;
    private const float ToggleSize = 0.036f;
    private const float PanelWidth = 0.48f;
    private const float PanelHeight = 0.34f;
    private const float RowHeight = 0.016f;
    private const float RowGap = 0.002f;
    private const float LeftWidth = 0.18f;
    private const float Padding = 0.008f;
    private const float IndentWidth = 0.012f;

    private readonly List<HierarchyRow> _hierarchyRows = new();
    private readonly List<GameObject> _visibleObjects = new();
    private bool _isVisible;
    private GameObject? _selectedGameObject;
    private framehandle _root = null!;
    private framehandle _toggleButton = null!;
    private framehandle _toggleText = null!;
    private framehandle _panel = null!;
    private framehandle _inspectorText = null!;
    private framehandle _emptyText = null!;
    private int _lastObjectCount = -1;

    public override void Awake()
    {
        CreateFrames();
        RefreshHierarchy();
        SelectFirstVisibleObject();
        SetPanelVisible(false);
    }

    public override void Update(float dt)
    {
        if (!_isVisible)
        {
            return;
        }

        if (_lastObjectCount != Scene.Instance.gameObjs.Count)
        {
            RefreshHierarchy();
        }

        if (_selectedGameObject == null || !SceneContains(_selectedGameObject))
        {
            SelectFirstVisibleObject();
        }

        RefreshInspectorText();
    }

    private void CreateFrames()
    {
        _root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0);

        _toggleButton = BlzCreateFrameByType("BUTTON", "FdfInspectorToggle", _root, "ScoreScreenTabButtonTemplate", 0);
        BlzFrameSetAbsPoint(_toggleButton, FRAMEPOINT_BOTTOMLEFT, 0.006f, 0.006f);
        BlzFrameSetSize(_toggleButton, ToggleSize, ToggleSize);

        _toggleText = BlzCreateFrameByType("TEXT", "FdfInspectorToggleText", _toggleButton, "", 0);
        BlzFrameSetAllPoints(_toggleText, _toggleButton);
        BlzFrameSetEnable(_toggleText, false);
        BlzFrameSetTextAlignment(_toggleText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER);
        BlzFrameSetText(_toggleText, "IN");

        var toggleTrigger = CreateTrigger();
        BlzTriggerRegisterFrameEvent(toggleTrigger, _toggleButton, FRAMEEVENT_CONTROL_CLICK);
        TriggerAddAction(toggleTrigger, TogglePanel);

        _panel = BlzCreateFrameByType("FRAME", "FdfInspectorPanel", _root, "", 0);
        BlzFrameSetAbsPoint(_panel, FRAMEPOINT_BOTTOMLEFT, 0.006f, 0.048f);
        BlzFrameSetSize(_panel, PanelWidth, PanelHeight);

        var panelBackdrop = BlzCreateFrame("EscMenuBackdrop", _panel, 0, 0);
        BlzFrameSetAllPoints(panelBackdrop, _panel);

        CreatePanelText("FDF Inspector", 0.012f, -0.012f, 0.14f, 0.016f, TEXT_JUSTIFY_LEFT);
        CreatePanelText("Hierarchy", Padding, -0.034f, LeftWidth - Padding * 2, 0.014f, TEXT_JUSTIFY_LEFT);
        CreatePanelText("Components", LeftWidth + Padding * 2, -0.034f, PanelWidth - LeftWidth - Padding * 3, 0.014f, TEXT_JUSTIFY_LEFT);

        var leftBackdrop = BlzCreateFrame("QuestButtonBaseTemplate", _panel, 0, 0);
        BlzFrameSetPoint(leftBackdrop, FRAMEPOINT_TOPLEFT, _panel, FRAMEPOINT_TOPLEFT, Padding, -0.052f);
        BlzFrameSetSize(leftBackdrop, LeftWidth - Padding * 2, PanelHeight - 0.066f);

        var rightBackdrop = BlzCreateFrame("QuestButtonBaseTemplate", _panel, 0, 0);
        BlzFrameSetPoint(rightBackdrop, FRAMEPOINT_TOPLEFT, _panel, FRAMEPOINT_TOPLEFT, LeftWidth + Padding, -0.052f);
        BlzFrameSetSize(rightBackdrop, PanelWidth - LeftWidth - Padding * 2, PanelHeight - 0.066f);

        for (var i = 0; i < MaxHierarchyRows; i++)
        {
            _hierarchyRows.Add(CreateHierarchyRow(i));
        }

        _inspectorText = BlzCreateFrameByType("TEXT", "FdfInspectorDetailsText", _panel, "", 0);
        BlzFrameSetPoint(_inspectorText, FRAMEPOINT_TOPLEFT, _panel, FRAMEPOINT_TOPLEFT, LeftWidth + Padding * 2, -0.061f);
        BlzFrameSetSize(_inspectorText, PanelWidth - LeftWidth - Padding * 4, PanelHeight - 0.082f);
        BlzFrameSetEnable(_inspectorText, false);
        BlzFrameSetTextAlignment(_inspectorText, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT);
        BlzFrameSetText(_inspectorText, string.Empty);

        _emptyText = BlzCreateFrameByType("TEXT", "FdfInspectorEmptyText", _panel, "", 0);
        BlzFrameSetPoint(_emptyText, FRAMEPOINT_TOPLEFT, _panel, FRAMEPOINT_TOPLEFT, Padding * 2, -0.066f);
        BlzFrameSetSize(_emptyText, LeftWidth - Padding * 4, 0.04f);
        BlzFrameSetEnable(_emptyText, false);
        BlzFrameSetTextAlignment(_emptyText, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT);
        BlzFrameSetText(_emptyText, "No GameObjects");
    }

    private void CreatePanelText(string text, float x, float y, float width, float height, textaligntype horizontalAlign)
    {
        var label = BlzCreateFrameByType("TEXT", "FdfInspectorLabel", _panel, "", 0);
        BlzFrameSetPoint(label, FRAMEPOINT_TOPLEFT, _panel, FRAMEPOINT_TOPLEFT, x, y);
        BlzFrameSetSize(label, width, height);
        BlzFrameSetEnable(label, false);
        BlzFrameSetTextAlignment(label, TEXT_JUSTIFY_TOP, horizontalAlign);
        BlzFrameSetText(label, text);
    }

    private HierarchyRow CreateHierarchyRow(int index)
    {
        var y = -0.061f - index * (RowHeight + RowGap);
        var button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", _panel, "ScoreScreenTabButtonTemplate", index);
        BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, _panel, FRAMEPOINT_TOPLEFT, Padding * 2, y);
        BlzFrameSetSize(button, LeftWidth - Padding * 4, RowHeight);

        var label = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index);
        BlzFrameSetPoint(label, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004f, -0.002f);
        BlzFrameSetSize(label, LeftWidth - Padding * 5, RowHeight - 0.003f);
        BlzFrameSetEnable(label, false);
        BlzFrameSetTextAlignment(label, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT);
        BlzFrameSetText(label, string.Empty);

        var row = new HierarchyRow(button, label);
        var trigger = CreateTrigger();
        BlzTriggerRegisterFrameEvent(trigger, button, FRAMEEVENT_CONTROL_CLICK);
        TriggerAddAction(trigger, () => SelectRow(row));
        BlzFrameSetVisible(button, false);
        return row;
    }

    private void TogglePanel()
    {
        SetPanelVisible(!_isVisible);
    }

    private void SetPanelVisible(bool visible)
    {
        _isVisible = visible;
        BlzFrameSetVisible(_panel, visible);
        BlzFrameSetText(_toggleText, visible ? "X" : "IN");

        if (visible)
        {
            RefreshHierarchy();
            if (_selectedGameObject == null)
            {
                SelectFirstVisibleObject();
            }
            RefreshInspectorText();
        }
    }

    private void SelectRow(HierarchyRow row)
    {
        if (row.gameObject == null)
        {
            return;
        }

        _selectedGameObject = row.gameObject;
        RefreshHierarchySelection();
        RefreshInspectorText();
    }

    private void SelectFirstVisibleObject()
    {
        _selectedGameObject = _visibleObjects.Count > 0 ? _visibleObjects[0] : null;
        RefreshHierarchySelection();
        RefreshInspectorText();
    }

    private void RefreshHierarchy()
    {
        _visibleObjects.Clear();

        foreach (var obj in Scene.Instance.gameObjs)
        {
            if (obj.transform.parent == null)
            {
                AddHierarchyObject(obj, 0);
            }
        }

        for (var i = 0; i < _hierarchyRows.Count; i++)
        {
            var row = _hierarchyRows[i];
            if (i < _visibleObjects.Count)
            {
                var obj = _visibleObjects[i];
                row.gameObject = obj;
                row.depth = GetDepth(obj);
                SetRowLabel(row, obj.name, row.depth);
                BlzFrameSetVisible(row.button, _isVisible);
            }
            else
            {
                row.gameObject = null;
                BlzFrameSetVisible(row.button, false);
            }
        }

        BlzFrameSetVisible(_emptyText, _isVisible && _visibleObjects.Count == 0);
        _lastObjectCount = Scene.Instance.gameObjs.Count;
        RefreshHierarchySelection();
    }

    private void AddHierarchyObject(GameObject obj, int depth)
    {
        if (_visibleObjects.Count >= MaxHierarchyRows)
        {
            return;
        }

        _visibleObjects.Add(obj);

        foreach (var child in obj.transform.children)
        {
            AddHierarchyObject(child.gameObject, depth + 1);
        }
    }

    private int GetDepth(GameObject obj)
    {
        var depth = 0;
        var parent = obj.transform.parent;
        while (parent != null)
        {
            depth++;
            parent = parent.parent;
        }
        return depth;
    }

    private void SetRowLabel(HierarchyRow row, string text, int depth)
    {
        BlzFrameClearAllPoints(row.label);
        BlzFrameSetPoint(row.label, FRAMEPOINT_TOPLEFT, row.button, FRAMEPOINT_TOPLEFT, 0.004f + depth * IndentWidth, -0.002f);
        BlzFrameSetSize(row.label, LeftWidth - Padding * 5 - depth * IndentWidth, RowHeight - 0.003f);
        BlzFrameSetText(row.label, text);
    }

    private void RefreshHierarchySelection()
    {
        foreach (var row in _hierarchyRows)
        {
            var isSelected = row.gameObject != null && row.gameObject == _selectedGameObject;
            BlzFrameSetTextColor(row.label, isSelected ? BlzConvertColor(255, 255, 220, 80) : BlzConvertColor(255, 230, 230, 230));
        }
    }

    private void RefreshInspectorText()
    {
        if (_selectedGameObject == null)
        {
            BlzFrameSetText(_inspectorText, string.Empty);
            return;
        }

        var text = _selectedGameObject.name + "\n";
        foreach (var component in _selectedGameObject.components)
        {
            text += "\n[" + component.GetInspectorName() + "]";
            var inspectorText = component.GetInspectorText();
            if (inspectorText != string.Empty)
            {
                text += "\n" + inspectorText;
            }
        }

        BlzFrameSetText(_inspectorText, text);
    }

    private bool SceneContains(GameObject gameObject)
    {
        foreach (var obj in Scene.Instance.gameObjs)
        {
            if (obj == gameObject)
            {
                return true;
            }
        }
        return false;
    }

    private class HierarchyRow
    {
        public readonly framehandle button;
        public readonly framehandle label;
        public GameObject? gameObject;
        public int depth;

        public HierarchyRow(framehandle button, framehandle label)
        {
            this.button = button;
            this.label = label;
        }
    }
}