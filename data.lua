-- These are some style prototypes that the tutorial uses
-- You don't need to understand how these work to follow along
local styles = data.raw["gui-style"].default

styles["bcc_foldable_frame"] = {
    type = "frame_style",
    margin = 0,
    padding = 0,
}

styles["bcc_invisi_frame"] = {
    type = "frame_style",
    margin = 0,
    padding = 0,
}

styles["bcc_content_frame"] = {
    parent = "inside_shallow_frame_with_padding",
    type = "frame_style",
    -- height = 120
}

styles["bcc_h_flow"] = {
    type = "horizontal_flow_style",
    margin = 0,
    padding = 0,
}


styles["bcc_data_table"] = {
    type = "table_style",
    -- can I do stripey rows?
}

styles["bcc_table_heading"] = {
    type = "label_style",
    font = "default-bold"
}

styles["bcc_nil_cell"] = {
    type = "label_style",
    font_color = { 0.5, 0.5, 0.5 },
}

styles["bcc_string_cell"] = {
    type = "label_style",
    height = 50
}



data:extend {
    { -- shortcut icon
        name = "bcc_toggle_gui",
        type = "shortcut",
        action = "lua",
        associated_control_input = "bcc_toggle_gui",
        toggleable = false,
        icon = {
            filename = "__base__/graphics/icons/locomotive.png",
            size = 64
        }
    },
    {
        type = "custom-input",
        name = "bcc_toggle_gui",
        localised_name = { "shortcut-name.bcc_toggle_gui" },
        key_sequence = "ALT + L",
        order = "a",
    },
    { -- reset icon
        name = "bcc_reset_gui",
        type = "shortcut",
        action = "lua",
        associated_control_input = "bcc_reset_gui",
        toggleable = false,
        icon = {
            filename = "__base__/graphics/icons/cargo-wagon.png",
            size = 64
        }
    },
    {
        type = "custom-input",
        name = "bcc_reset_gui",
        localised_name = { "shortcut-name.bcc_reset_gui" },
        key_sequence = "ALT + ;",
        order = "a",
    }
}
