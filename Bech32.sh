#!/usr/bin/env bash
set -e; set -u; set -o pipefail;
#set -x;

function bech32_checksum () {
    c=1
    for v_i in $@; do
    c0=$(( c >> 25 ))

    # shift 5 bit to the left (aka multiply the by x) and XOR (aka add v_i value)
    c=$(( ((c & 0x1ffffff) << 5) ^ v_i ))

    if ((c0 & 1)); then
        c=$(( c ^ 0x3b6a57b2 ))
    fi
    if ((c0 & 2)); then
        c=$(( c ^ 0x26508e6d ))
    fi
    if ((c0 & 4)); then
        c=$(( c ^ 0x1ea119fa ))
    fi
    if ((c0 & 8)); then
        c=$(( c ^ 0x3d4233dd ))
    fi
    if ((c0 & 16)); then
        c=$(( c ^ 0x2a1462b3 ))
    fi
    done

    mod=$(( c ^ 1 ))

    # convert into 6 groups of 5-bit each
    checksum=()
    for i in {0..5}; do
    checksum[$i]=$(( (mod >> 5 * (5-i)) & 31 ))
    done

    # return array expansion
    echo ${checksum[@]}
}


openssl ecparam -genkey -name secp256k1 -out /tmp/secret.pem
key=$(openssl ec -pubout -in /tmp/secret.pem -outform DER | tail -c 65 | xxd -p -c 65)
sha256=$(echo $key | xxd -r -p | openssl sha256 | cut -f 2 -d ' ')
ripemd160=$(echo $sha256 | xxd -r -p | openssl ripemd160 | cut -f 2 -d ' ')
program_bin=( $(echo $ripemd160 | xxd -r -p | xxd -b -c 20 -g 0 | cut -f 2 -d ' ' | grep -o '[01]\{5\}') )
program_dec=$(for b in ${program_bin[@]}; do echo "ibase=2;$b" | bc; done)
hrp_dec=(3 3 0 2 3)
ver_dec=(0)
cs_dec=(0 0 0 0 0 0)
data=(${hrp_dec[@]} ${ver_dec[@]} ${program_dec[@]} ${cs_dec[@]})
checksum=$(bech32_checksum ${data[@]})
CHARSET=(q p z r y 9 x 8 g f 2 t v d w 0 s 3 j n 5 4 k h c e 6 m u a 7 l)
address="bc1"
for v in ${ver_dec[@]}; do address+=${CHARSET[v]}; done
for p in ${program_dec[@]}; do address+=${CHARSET[p]}; done
for c in ${checksum[@]}; do address+=${CHARSET[c]}; done
echo $address
