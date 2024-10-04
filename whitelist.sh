#!/bin/bash

echo "====================================================="
echo "====Whitelist/Blacklist IP Imunify360 ==="
echo "====================================================="
echo "1. Whitelist IP Static by port 2087 WHM"
echo "2. Whitelist IP Dinamic by 24 Jam full access"
echo "3. Hapus IP dalam list block port 423, 2087, 7989 dan 2086"
echo "4. Blacklist IP"
echo "5. Whitelist IP Custom Block Port 423, 2087, 7080 dan 2086"
echo "6. Hapus IP dalam whiteist"
echo "7. Hapus IP dalam blacklist"
echo "8. Cek white/black list IP"
echo "9. Whitelist IP Dinamic Custom"
echo "============================================"

read -p "Pilih Nomor = " select
read -p "Masukan IP = " IP

# Hanya minta custom whitelist jika pilihan nya 9
if [ "$select" = "9" ]; then
    echo "----------------------------------------------------------------"
    echo "Pilih Mau berapa hari whitelist nya, semua default full access"
    echo "----------------------------------------------------------------"
    echo "1. 1 Hari"
    echo "2. 2 hari"
    echo "3. 3 Hari"
    echo "4. 4 Hari"
    echo "5. 5 Hari"
    read -p "Masukan Nomor di atas = " hari
fi

# Hanya minta port jika pilihannya adalah 5
if [ "$select" = "5" ] || [ "$select" = "3" ]; then
    read -p "Masukan Port = " port
fi

# Hanya minta "note" jika pilihannya adalah 1, 2, 4, 5, dan 9
if [ "$select" = "1" ] || [ "$select" = "2" ] || [ "$select" = "4" ] || [ "$select" = "5" ] || [ "$select" = "9" ]; then
    read -p "Masukan Note = " note
fi
# jika pilih 1 untuk whitelist static ke port 287
if [ "$select" = "1" ]; then
    if imunify360-agent blocked-port list | grep -q "$IP.*2087"; then
        echo "IP $IP sudah ada di block port 2087. Menghapus terlebih dahulu..."
        imunify360-agent blocked-port-ip delete 2087:tcp --ips $IP >/dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "IP $IP berhasil dihapus dari block port 2087."
        else
            echo "Gagal menghapus IP $IP dari block port 2087."
            exit 1  # Keluar jika gagal menghapus
        fi
    fi

    # Menambahkan ulang IP ke blokir port 2087
    imunify360-agent blocked-port-ip add 2087:tcp --ips $IP --comment "$note" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "IP $IP berhasil ditambahkan ke block port 2087."
    else
        echo "Gagal menambahkan IP $IP ke block port 2087 silakan periksa kembali IP nya pastikan sudah sesuai.."
    fi
#jika pilih 2 whitelist 24 jam dinamis
elif [ "$select" = "2" ]; then

    if imunify360-agent ip-list local list | grep -q "$IP"; then
        echo "IP $IP sudah ada di daftar. Menghapus terlebih dahulu..."
        imunify360-agent ip-list local delete --purpose white "$IP" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "IP $IP berhasil dihapus."
        else
            echo "Gagal menghapus IP $IP dari daftar."
            exit 1
        fi
    else
        echo "IP $IP belum ada di daftar. Menambahkan IP baru..."
    fi

    imunify360-agent ip-list local add --purpose white "$IP" --comment "$note" --expiration $(($(date "+%s")+86400)) --full-access >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "IP $IP telah ditambahkan ke whitelist dengan catatan '$note' dan kadaluarsa dalam 24 jam."
    else
        echo "Gagal menambahkan IP $IP ke whitelist silakan periksa kembali IP nya pastikan sudah sesuai."
    fi

# jika pilih 3 hapus IP dari custom port
elif [ "$select" = "3" ]; then
    if imunify360-agent blocked-port list | grep -q "$IP.*$port"; then
        # Jika IP ada, hapus dari blocked port
        imunify360-agent blocked-port-ip delete $port:tcp --ips $IP >/dev/null 2>&1

        if [ $? -eq 0 ]; then
            echo "IP $IP berhasil dihapus dari block port $port."
        else
            echo "Gagal menghapus IP $IP dari block port $port."
        fi
    else
        # Jika IP tidak ada dalam daftar blocked port
        echo "Gagal hapus IP $IP tidak ada dalam list block port $port."
    fi
#jika pilih 4 blacklist IP
elif [ "$select" = "4" ]; then
    imunify360-agent ip-list local add --purpose drop $IP --comment "$note" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "IP $IP berhasil di blacklist dengan catatan $note"
    else

echo "Gagal blacklsit IP $IP pastikan IP sudah sesuai."
    fi
# jika pilih 5 whitelist ke block port custom
elif [ "$select" = "5" ]; then
    if imunify360-agent blocked-port list | grep -q "$IP.*$port"; then
        echo "IP $IP sudah ada di block port $port. Menghapus terlebih dahulu..."
        imunify360-agent blocked-port-ip delete $port:tcp --ips $IP >/dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "IP $IP berhasil dihapus dari block port $port."
        else
            echo "Gagal menghapus IP $IP dari block port $port."
            exit 1  # Keluar jika gagal menghapus
        fi
    fi

    # Menambahkan ulang IP ke blokir port tertentu
    imunify360-agent blocked-port-ip add $port:tcp --ips $IP --comment "$note" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "IP $IP berhasil ditambahkan ke block port $port."
    else
        echo "Gagal menambahkan IP $IP ke block port $port silakan periksa kembali IP nya pastikan sudah sesuai."
    fi
# jika pilih 6 hapus ip dari list whitelist dinamis
elif [ "$select" = "6" ]; then
    imunify360-agent ip-list local list --purpose white | grep -w $IP > /dev/null

    if [ $? -eq 0 ]; then
        # Jika IP ditemukan, hapus dari whitelist
        imunify360-agent ip-list local delete --purpose white $IP >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "IP $IP berhasil dihapus dari whitelist"
        else
            echo "Gagal menghapus IP $IP dari whitelist"
        fi
    else
        # Jika IP tidak ditemukan dalam whitelist
        echo "Gagal menghapus IP $IP tidak ada dalam whitelist"
    fi
# jika pilih 7 hapus ip dari blacklist
elif [ "$select" = "7" ]; then
    imunify360-agent ip-list local list --purpose drop | grep -w $IP > /dev/null

    if [ $? -eq 0 ]; then

        imunify360-agent ip-list local delete --purpose drop $IP > /dev/null
        if [ $? -eq 0 ]; then
            echo "IP $IP berhasil dihapus dari blacklist"
        else
            echo "Gagal menghapus IP $IP dalam blacklist"
        fi
    else
        echo "Gagal menghapus IP $IP tidak ada dalam blacklist"
    fi

# jika pilih 8 untuk cek list white/black list ip
elif [ "$select" = "8" ]; then
     imunify360-agent ip-list local list --purpose --by-ip $IP

    if imunify360-agent ip-list local list --purpose white --by-ip "$IP" | grep -q "$IP"; then
    echo -e "\e[32mIP $IP\e[0m ada di whitelist."
# Cek apakah IP ada di blacklist
elif imunify360-agent ip-list local list --purpose drop --by-ip "$IP" | grep -q "$IP"; then
    echo -e "\e[31mIP $IP\e[0m ada di blacklist."
else
    echo "IP $IP tidak ada di whitelist maupun blacklist."
fi
# custom hari
elif [ "$select" = "9" ]; then

    validate_input() {
    if [[ "$1" =~ ^[1-5]$ ]]; then
        return 0  # Valid
    else
        return 1  # Tidak valid
    fi
    }
       if ! validate_input "$hari"; then
    echo "Pilihan tidak valid! Harap pilih nomor antara 1 sampai 5."
    exit 1
        fi

# Menghitung jumlah detik untuk expiration berdasarkan pilihan hari
    case "$hari" in
    1) expiration_seconds=$((86400)) ;; # 1 hari = 86400 detik
    2) expiration_seconds=$((86400 * 2)) ;; # 2 hari
    3) expiration_seconds=$((86400 * 3)) ;; # 3 hari
    4) expiration_seconds=$((86400 * 4)) ;; # 4 hari
    5) expiration_seconds=$((86400 * 5)) ;; # 5 hari
    esac 
if imunify360-agent ip-list local list | grep -q "$IP"; then
        echo "IP $IP sudah ada di daftar. Menghapus terlebih dahulu..."
        imunify360-agent ip-list local delete --purpose white "$IP" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "IP $IP berhasil dihapus."
        else
            echo "Gagal menghapus IP $IP dari daftar."
            exit 1
        fi
    else
        echo "IP $IP belum ada di daftar. Menambahkan IP baru..."
    fi

    # Menambahkan IP dengan aturan baru
    imunify360-agent ip-list local add --purpose white "$IP" --comment "$note" --expiration $(($(date "+%s") + $expiration_seconds)) --full-access >/dev/null 2>&1

    # Cek apakah penambahan IP berhasil
    if [ $? -eq 0 ]; then
        echo "IP $IP telah ditambahkan ke whitelist dengan catatan '$note' dan kadaluarsa dalam $hari hari."
    else
        echo "Gagal menambahkan IP $IP ke whitelist silakan periksa kembali IP nya pastikan sudah sesuai."
    fi

else
    echo "Pilihan tidak sesuai"
fi

