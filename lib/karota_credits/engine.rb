# frozen_string_literal: true

module ::KarotaCredits
	PLUGIN_NAME = "KarotaCredits"

	class Engine < ::Rails::Engine
		engine_name KarotaCredits::PLUGIN_NAME
		isolate_namespace KarotaCredits
	end
end
