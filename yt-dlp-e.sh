#!/data/data/com.termux/files/usr/bin/bash
clear

# Fungsi untuk menampilkan pesan error tanpa menghentikan script
error_message() {
    echo -e "\033[1;31mError: $1\033[0m" >&2
}

# Fungsi untuk mendapatkan informasi dari URL menggunakan yt-dlp
get_info() {
    yt-dlp -F "$1" 2>/dev/null || error_message "Gagal mendapatkan informasi dari URL."
}

# Fungsi untuk mendapatkan judul video/audio dari URL menggunakan yt-dlp
get_title() {
    yt-dlp --get-title "$1" 2>/dev/null || error_message "Gagal mendapatkan judul dari URL."
}

# Fungsi untuk menampilkan opsi download
show_options() {
    echo -e "\033[1;32mItem yang bisa didownload:\033[0m"
    echo "----------------------------------------"
    echo -e "1. \033[1;36mVideo\033[0m"
    echo -e "2. \033[1;36mAudio\033[0m"
    echo -e "3. \033[1;36mVideo + Audio\033[0m"
    echo "----------------------------------------"
}

# Fungsi untuk mendownload item berdasarkan pilihan
download_item() {
    local url=$1
    local item_type=$2
    local output_dir=$3
    local output_template

    case $item_type in
        video)
            echo -e "\033[1;32mKualitas video yang tersedia:\033[0m"
            echo "----------------------------------------"
            get_info "$url" | grep "video" | awk '{print NR, $0}'
            echo "----------------------------------------"
            echo -e "\033[1;34mPilih kualitas video (nomor): \033[0m"
            read quality_number
            selected_quality=$(get_info "$url" | grep "video" | awk -v num=$quality_number 'NR==num {print $1}')
            title=$(get_title "$url")
            echo -e "\033[1;32m$title akan didownload dengan kualitas $selected_quality.\033[0m"
            output_template="${output_dir}/%(title)s-%(uploader)s-%(resolution)s.%(ext)s"
            yt-dlp -f "$selected_quality" -o "$output_template" "$url" || error_message "Gagal mendownload video."
            ;;
        audio)
            echo -e "\033[1;32mKualitas audio yang tersedia:\033[0m"
            echo "----------------------------------------"
            get_info "$url" | grep "audio" | awk '{print NR, $0}'
            echo "----------------------------------------"
            echo -e "\033[1;34mPilih kualitas audio (nomor): \033[0m"
            read quality_number
            selected_quality=$(get_info "$url" | grep "audio" | awk -v num=$quality_number 'NR==num {print $1}')
            title=$(get_title "$url")
            echo -e "\033[1;32m$title akan didownload dengan kualitas $selected_quality.\033[0m"
            output_template="${output_dir}/%(title)s-%(uploader)s.%(ext)s"
            yt-dlp -f "$selected_quality" -o "$output_template" "$url" || error_message "Gagal mendownload audio."
            ;;
        video_audio)
            echo -e "\033[1;32mKualitas video yang tersedia:\033[0m"
            echo "----------------------------------------"
            get_info "$url" | grep "video" | awk '{print NR, $0}'
            echo "----------------------------------------"
            echo -e "\033[1;34mPilih kualitas video (nomor): \033[0m"
            read video_quality_number
            selected_video_quality=$(get_info "$url" | grep "video" | awk -v num=$video_quality_number 'NR==num {print $1}')

            echo -e "\033[1;32mKualitas audio yang tersedia:\033[0m"
            echo "----------------------------------------"
            get_info "$url" | grep "audio" | awk '{print NR, $0}'
            echo "----------------------------------------"
            echo -e "\033[1;34mPilih kualitas audio (nomor): \033[0m"
            read audio_quality_number
            selected_audio_quality=$(get_info "$url" | grep "audio" | awk -v num=$audio_quality_number 'NR==num {print $1}')

            title=$(get_title "$url")
            echo -e "\033[1;32m$title akan didownload dengan kualitas video $selected_video_quality dan kualitas audio $selected_audio_quality.\033[0m"
            output_template="${output_dir}/%(title)s-%(uploader)s-%(resolution)s.%(ext)s"
            yt-dlp -f "$selected_video_quality+$selected_audio_quality" -o "$output_template" --postprocessor-args "ffmpeg:-c copy -map 0:v -map 1:a -movflags +faststart -y -loglevel error" "$url" || error_message "Gagal mendownload video + audio."
            ;;
        *)
            error_message "Pilihan tidak valid."
            ;;
    esac
}

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

    # Meminta direktori output dari user
    echo -e "\033[1;34mMasukkan direktori output (default: /storage/emulated/0/Downloads/dvd): \033[0m"
    read output_dir
    output_dir=${output_dir:-"/storage/emulated/0/Downloads/dvd"}

    # Memastikan direktori output ada
    mkdir -p "$output_dir" || error_message "Gagal membuat direktori output."

    # Menampilkan opsi download
    show_options

    # Meminta user untuk memilih item yang ingin didownload
    echo -e "\033[1;34mPilih item yang ingin didownload (nomor): \033[0m"
    read item_number

    case $item_number in
        1) item_type="video" ;;
        2) item_type="audio" ;;
        3) item_type="video_audio" ;;
        *) error_message "Pilihan tidak valid." ;;
    esac

    # Mendownload item berdasarkan pilihan
    download_item "$url" "$item_type" "$output_dir"

    echo -e "\033[1;32mDownload selesai.\033[0m"
done