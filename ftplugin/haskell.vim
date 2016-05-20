command! -buffer -range -nargs=0 InteroTypeStr echo intero#type(input('Expression: '))
command! -buffer -range -nargs=0 InteroType echo intero#ranged('type-at')
command! -buffer -range -nargs=0 InteroUses call intero#uses()
command! -buffer -range -nargs=0 InteroGoto call intero#gotodef()
