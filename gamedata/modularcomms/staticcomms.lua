local comms = {
  comm_guardian = { 
	chassis = "armcom2", 
	name = "Star Guardian",
	modules = { "commweapon_beamlaser", "module_ablative_armor", "module_high_power_servos", "module_high_power_servos", "weaponmod_high_frequency_beam", "module_energy_cell"},
  },
  comm_riot = {
    chassis = "corcom2",
	name = "Crowd Controller",
    modules = { "commweapon_riotcannon", "commweapon_heatray"},
  },
  comm_recon = {
    chassis = "commrecon2",
	name = "Ghost Recon",
    modules = { "commweapon_heatray", "module_ablative_armor", "module_high_power_servos", "module_high_power_servos", "module_jammer" , "module_autorepair"},
  },
  comm_rocketeer = {
    chassis = "armcom2",
	name = "Rocket Surgeon",
    modules = { "commweapon_rocketlauncher", "module_dmg_booster", "module_adv_targeting", "module_ablative_armor" },
  },
  comm_marksman = {
    chassis = "commsupport2",
	name = "The Marksman",
    modules = { "commweapon_gaussrifle", "module_dmg_booster", "module_adv_targeting", "module_ablative_armor" , "module_high_power_servos"},
  },  
  comm_flamer = {
    chassis = "corcom2",
	name = "The Fury",
    modules = { "commweapon_flamethrower", "module_dmg_booster", "module_ablative_armor", "module_ablative_armor", "module_high_power_servos"},
  },
  comm_marine = {
    chassis = "commrecon2",
	name = "Space Marine",
    modules = { "commweapon_heavymachinegun", "module_heavy_armor", "module_high_power_servos", "module_dmg_booster", "module_adv_targeting"},
  },
  comm_hunter = {
    chassis = "commsupport2",
	name = "Bear Hunter",
    modules = { "commweapon_shotgun", "module_dmg_booster", "module_adv_targeting", "module_high_power_servos", "module_fieldradar"},
  },
  comm_special = {
    chassis = "cremcom3",
	name = "Lady of War",
    modules = { "commweapon_heavymachinegun", "commweapon_gaussrifle", "module_ablative_armor", "module_ablative_armor", "module_dmg_booster",
				"module_adv_targeting", "module_high_power_servos", "weaponmod_disruptor_ammo"},
  },
}

for name,stats in pairs(comms) do
	table.insert(stats.modules, "module_econ")
end

return comms