/datum/admin_secret_item/fun_secret/paintbal_mode
	name = "Paintball Mode"

/datum/admin_secret_item/fun_secret/paintbal_mode/execute(mob/user)
	. = ..()
	if(!.)
		return

	for(var/species in all_species)
		var/datum/species/S = all_species[species]
		S.blood_color = "rainbow"
	for(var/obj/effect/decal/cleanable/blood/B in global.cleanable_decals_list)
		B.basecolor = "rainbow"
		B.update_icon()
