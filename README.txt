## TO CONVERT AUDIO USE
afconvert -f caff -d 'aac '@24000 input.m4a output.caf

## WHILE IN irb
1.upto(2) {|v| 1.upto(9) {|t| `afconvert -f caff -d 'aac '@24000 Sounds/aac\\ buddha\\ loops/BM#{v}0#{t}iphone.m4a Sounds/v#{v}_hi0#{t}.caf`}}
