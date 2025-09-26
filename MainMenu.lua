local Gui = script.Parent.Parent -- The main menu UI

script.Parent.MouseButton1Click:Connect(function(clicked) -- When the play button is clicked
	Gui:TweenPosition(UDim2.new(0,0,1,0), "InOut", "Sine",3.5) -- Animate the UI off the screen
	for i = 1,25 do -- A loop to make the blur effect fade out
		wait (0.05) -- Wait 0.05 seconds
		game.Lighting.Blur.Size = game.Lighting.Blur.Size - 3 -- Make the blur size smaller
	end
end)
