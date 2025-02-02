/mob/living/carbon/alien/larva/proc/check_can_infest(mob/living/M)
	if(!src)
		return 0
	if(!istype(loc, /turf))
		to_chat(src, SPAN_DANGER("You cannot infest a target in your current position."))
		return 0
	if(incapacitated())
		to_chat(src, SPAN_DANGER("You cannot infest a target in your current state."))
		return 0
	if(!M)
		return 1
	if(!M.lying)
		to_chat(src, SPAN_DANGER("\The [M] is not prone."))
		return 0
	if(!(src.Adjacent(M)))
		to_chat(src, SPAN_DANGER("\The [M] is not in range."))
		return 0
	return 1

/mob/living/carbon/alien/larva/verb/attach_host()

	set name = "Attach to host"
	set desc = "Burrow into a prone victim and begin drinking their blood."
	set category = "Abilities"

	if(!check_can_infest())
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(1,src))
		if(isxenomorph(H))
			continue
		if(src.Adjacent(H) && H.lying)
			choices += H

	if(!choices.len)
		to_chat(src, SPAN_DANGER("There are no viable hosts within range."))
		return

	var/mob/living/carbon/human/H = input(src,"Who do you wish to infest?") as null|anything in choices

	if(!H || !src || !H.lying) return

	visible_message(SPAN_DANGER("\The [src] begins questing blindly towards \the [H]'s warm flesh..."))

	if(!do_after(src,30, H))
		return

	if(!check_can_infest(H))
		return

	var/obj/item/organ/external/E = pick(H.organs)
	to_chat(src, SPAN_DANGER("You burrow deeply into \the [H]'s [E.name]!"))
	var/obj/item/weapon/holder/holder = new (loc)
	src.loc = holder
	holder.SetName(src.name)
	E.embed(holder,0,"\The [src] burrows deeply into \the [H]'s [E.name]!")

/mob/living/carbon/alien/larva/verb/release_host()
	set category = "Abilities"
	set name = "Release Host"
	set desc = "Release your host."

	if(incapacitated())
		to_chat(src, "You cannot leave your host in your current state.")
		return

	if(!loc || !loc.loc)
		to_chat(src, "You are not inside a host.")
		return

	var/mob/living/carbon/human/H = loc.loc

	if(!istype(H))
		to_chat(src, "You are not inside a host.")
		return

	to_chat(src, SPAN_DANGER("You begin writhing your way free of \the [H]'s flesh..."))

	if(!do_after(src, 30, H))
		return

	if(!H || !src)
		return

	leave_host()

/mob/living/carbon/alien/larva/proc/leave_host()
	if(!loc || !loc.loc)
		to_chat(src, "You are not inside a host.")
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!istype(H))
		to_chat(src, "You are not inside a host.")
		return
	var/obj/item/weapon/holder/holder = loc
	var/obj/item/organ/external/affected
	if(istype(holder))
		for(var/obj/item/organ/external/organ in H.organs) //Grab the organ holding the implant.
			for(var/obj/item/O in organ.implants)
				if(O == holder)
					affected = organ
					break
		affected.implants -= holder
		holder.loc = get_turf(holder)
	else
		src.loc = get_turf(src)
	if(affected)
		to_chat(src, SPAN_DANGER("You crawl out of \the [H]'s [affected.name] and plop to the ground."))
	else
		to_chat(src, SPAN_DANGER("You plop to the ground."))
