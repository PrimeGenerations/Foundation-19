// We really need some datums for this.
/obj/item/weapon/coilgun_assembly
	name = "coilgun stock"
	desc = "It might be a coilgun, someday."
	icon = 'icons/obj/coilgun.dmi'
	icon_state = "coilgun_construction_1"

	var/construction_stage = 1

/obj/item/weapon/coilgun_assembly/attackby(obj/item/thing, mob/user)

	if(istype(thing, /obj/item/stack/material) && construction_stage == 1)
		var/obj/item/stack/material/reinforcing = thing
		var/material/reinforcing_with = reinforcing.get_material()
		if(reinforcing_with.name == DEFAULT_WALL_MATERIAL) // Steel
			if(reinforcing.get_amount() < 5)
				to_chat(user, SPAN_WARNING("You need at least 5 [reinforcing.singular_name]\s for this task."))
				return
			reinforcing.use(5)
			user.visible_message(SPAN_NOTICE("\The [user] shapes some steel sheets around \the [src] to form a body."))
			increment_construction_stage()
			return

	if(istype(thing, /obj/item/weapon/tape_roll) && construction_stage == 2)
		user.visible_message(SPAN_NOTICE("\The [user] secures \the [src] together with \the [thing]."))
		increment_construction_stage()
		return

	if(istype(thing, /obj/item/pipe) && construction_stage == 3)
		user.drop_from_inventory(thing)
		qdel(thing)
		user.visible_message(SPAN_NOTICE("\The [user] jams \the [thing] into \the [src]."))
		increment_construction_stage()
		return

	if(isWelder(thing) && construction_stage == 4)
		var/obj/item/weapon/weldingtool/welder = thing

		if(!welder.isOn())
			to_chat(user, SPAN_WARNING("Turn it on first!"))
			return

		if(!welder.remove_fuel(0,user))
			to_chat(user, SPAN_WARNING("You need more fuel!"))
			return

		user.visible_message(SPAN_NOTICE("\The [user] welds the barrel of \the [src] into place."))
		playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
		increment_construction_stage()
		return

	if(isCoil(thing) && construction_stage == 5)
		var/obj/item/stack/cable_coil/cable = thing
		if(cable.get_amount() < 5)
			to_chat(user, SPAN_WARNING("You need at least 5 lengths of cable for this task."))
			return
		cable.use(5)
		user.visible_message(SPAN_NOTICE("\The [user] wires \the [src]."))
		increment_construction_stage()
		return

	if(istype(thing, /obj/item/weapon/smes_coil) && construction_stage >= 6 && construction_stage <= 8)
		user.visible_message(SPAN_NOTICE("\The [user] installs \a [thing] into \the [src]."))
		user.drop_from_inventory(thing)
		qdel(thing)
		increment_construction_stage()
		return

	if(isScrewdriver(thing) && construction_stage >= 9)
		user.visible_message(SPAN_NOTICE("\The [user] secures \the [src] and finishes it off."))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		var/obj/item/weapon/gun/magnetic/coilgun = new(loc)
		var/put_in_hands
		var/mob/M = src.loc
		if(istype(M))
			put_in_hands = M == user
			M.drop_from_inventory(src)
		if(put_in_hands)
			user.put_in_hands(coilgun)
		qdel(src)
		return

	return ..()

/obj/item/weapon/coilgun_assembly/proc/increment_construction_stage()
	if(construction_stage < 9)
		construction_stage++
	icon_state = "coilgun_construction_[construction_stage]"

/obj/item/weapon/coilgun_assembly/examine(mob/user)
	. = ..(user,2)
	if(.)
		switch(construction_stage)
			if(2) to_chat(user, SPAN_NOTICE("It has a metal frame loosely shaped around the stock."))
			if(3) to_chat(user, SPAN_NOTICE("It has a metal frame duct-taped to the stock."))
			if(4) to_chat(user, SPAN_NOTICE("It has a length of pipe attached to the body."))
			if(4) to_chat(user, SPAN_NOTICE("It has a length of pipe welded to the body."))
			if(6) to_chat(user, SPAN_NOTICE("It has a cable mount and capacitor jack wired to the frame."))
			if(7) to_chat(user, SPAN_NOTICE("It has a single superconducting coil threaded onto the barrel."))
			if(8) to_chat(user, SPAN_NOTICE("It has a pair of superconducting coils threaded onto the barrel."))
			if(9) to_chat(user, SPAN_NOTICE("It has three superconducting coils attached to the body, waiting to be secured."))
