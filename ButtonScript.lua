local button = script.Parent -- The button script
local frame = button.Parent:WaitForChild("PhoneFrame")	-- The frame to toggle

frame.Visible = false -- Hide the frame initially

button.MouseButton1Click:Connect(function() -- When the button is clicked
	frame.Visible = not frame.Visible -- Toggle the frame's visibility
	print("Frame visible?", frame.Visible) -- CHecking if the frame is visible (Debug)
end) 


local button =script.Parent

-- ALL OF THE BUTTONS ARE USING THIS CODE THE ONLY CODE THAT IS CHANGED FOR EACH BUTTON INSIDE THE SIDE GUI IS LINE 2 WHERE THE CHILD INSIDE THE BRACKESTS ARE DIFFRENT
