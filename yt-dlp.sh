#!/data/data/com.termux/files/usr/bin/bash
clear
# Fungsi untuk menampilkan pesan error dan keluar dengan warna merah
error_exit() {
    echo -e "\033[1;31mError: $1\033[0m" >&2
    exit 1
}

# Tentukan direktori download
output_dir="/storage/emulated/0/Downloads/dvd"

# Loop utama
while true; do
    # Meminta URL dari user
    echo -e "\033[1;34mMasukkan URL (atau tekan enter untuk keluar): \033[0m"
    read url

    # Jika URL kosong, keluar dari loop
    if [ -z "$url" ]; then
        echo -e "\033[1;32mTerima kasih! Program selesai.\033[0m"
        break
    fi

    # Mendapatkan informasi dari URL menggunakan yt-dlp
    info=$(yt-dlp -F "$url" 2>/dev/null) || error_exit "Gagal mendapatkan informasi dari URL."

    # Menampilkan list item yang bisa didownload
    echo -e "\033[1;32mItem yang bisa didownload:\033[0m"
    echo "----------------------------------------"
    echo -e "1. \033[1;36mVideo\033[0m"
    echo -e "2. \033[1;36mAudio\033[0m"
    echo -e "3. \033[1;36mSubtitle\033[0m"
    echo -e "4. \033[1;36mThumbnail\033[0m"
    echo "----------------------------------------"

    # Meminta user untuk memilih item yang ingin didownload
    echo -e "\033[1;34mPilih item yang ingin didownload (nomor): \033[0m"
    read item_number

    case $item_number in
        1) item_type="video" ;;
        2) item_type="audio" ;;
        3) item_type="subtitle" ;;
        4) item_type="thumbnail" ;;
        *) error_exit "Pilihan tidak valid." ;;
    esac

    # Meminta user untuk memilih kualitas atau bahasa/format subtitle
    case $item_type in
        video|audio)
            echo -e "\033[1;32mKualitas yang tersedia:\033[0m"
            echo "----------------------------------------"
            echo "$info" | grep "$item_type" | awk '{print NR, $0}'
            echo "----------------------------------------"
            echo -e "\033[1;34mPilih kualitas (nomor): \033[0m"
            read quality_number
            selected_quality=$(echo "$info" | grep "$item_type" | awk -v num=$quality_number 'NR==num {print $1}')
            ;;
        subtitle)
            echo -e "\033[1;32mBahasa dan format subtitle yang tersedia:\033[0m"
            echo "----------------------------------------"
            echo "$info" | grep "subtitle" | awk '{print NR, $0}'
            echo "----------------------------------------"
            echo -e "\033[1;34mPilih subtitle (nomor): \033[0m"
            read subtitle_number
            selected_subtitle=$(echo "$info" | grep "subtitle" | awk -v num=$subtitle_number 'NR==num {print $1}')
            ;;
        thumbnail)
            selected_quality="thumbnail"
            ;;
    esac

    # Menentukan template penamaan file khusus untuk YouTube
    if [[ "$url" == *"youtube.com"* || "$url" == *"youtu.be"* ]]; then
        case $item_type in
            video)
                output_template="${output_dir}/%(title)s-%(uploader)s-%(resolution)s.%(ext)s"
                ;;
            audio)
                output_template="${output_dir}/%(title)s-%(uploader)s.%(ext)s"
                ;;
            subtitle|thumbnail)
                output_template="${output_dir}/%(title)s.%(ext)s"
                ;;
        esac
    else
        output_template="${output_dir}/%(title)s.%(ext)s"
    fi

    # Eksekusi download berdasarkan item yang dipilih
    if [ "$item_type" == "subtitle" ]; then
        yt-dlp -o "$output_template" --write-subs --sub-langs "$selected_subtitle" "$url" || error_exit "Gagal mendownload subtitle."
    elif [ "$item_type" == "thumbnail" ]; then
        yt-dlp --write-thumbnail --skip-download -o "$output_template" "$url" || error_exit "Gagal mendownload thumbnail."
    else
        yt-dlp -f "$selected_quality" -o "$output_template" "$url" || error_exit "Gagal mendownload $item_type."
    fi

    echo -e "\033[1;32mDownload selesai.\033[0m"
done
