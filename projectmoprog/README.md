# Mobile Programming - GETCONTACT

## Tentang
Perkembangan teknologi komunikasi pada perangkat mobile semakin meningkat pesat dan menjadi suatu hal yang tidak bisa dipisahkan dari kehidupan sehari-hari. Namun, bahaya dari perkembangan tersebut juga semakin meningkat pula dengan adanya panggilan tidak dikenal yang berpotensi sebagai spam, penipuan, maupun aktivitas yang tidak diinginkan.

Salah satu aplikasi yang mencegah hal tersebut adalah GetContact. Sebuah aplikasi mobile yang menyediakan fitur identifikasi nomor, pencarian kontak, pemberian tag, serta perlindungan pengguna dari nomor mengganggu.

Maka dari itu, kami disini mencoba untuk mengembangkan sebuah aplikasi yang terinspirasi dengan konsep dari aplikasi GetContact. Aplikasi ini kami buat dengan menggunakan Flutter dan Dart, serta juga integrasi database menggunakan Supabase.

## Fitur
Beberapa fitur yang telah kami buat pada aplikasi ini dapat dikategorikan menjadi beberapa cakupan sebagai berikut:
1. User
    - Pembuatan akun, fitur ini merupakan fitur pertama yang akan ditemui oleh user. User akan diminta untuk memasukkan nama, nomor telepon (serta dengan awalan kode nomor negara), serta password untuk meng-register akun baru ke dalam aplikasi.
    - Autentifikasi, mengecek akun yang berusaha untuk login dan melihat apakah datanya sesuai dengan data yang terdaftar di database atau tidak.
    - Account Settings, fitur ini dapat mengedit informasi user, diantaranya terdiri dari profil gambar akun, username, dan nomor telepon user
    - Manage Account, fitur ini digunakan untuk mengubah password dari akun ataupun menghapus akun dari database.
    - Birthday, fitur ini merupakan fitur tambahan dari kelola akun dimana fitur ini digunakan untuk mencatat tanggal ulang tahun user yang sudah diinput dahulu sebelumnya. 
    - Profile Summary, fitur yang digunakan untuk membuat summary bio dari akun user menggunakan template kata yang sudah disiapkan aplikasi berdasarkan kategori yang telah dipilih.

2. Settings
    - Theme Aplikasi, fitur yang digunakan untuk mengatur mode visual aplikasi (Light Mode/Dark Mode).
    - Notification Setting, fitur yang digunakan untuk menyalakan dan mematikan fitur notifikasi.
    - Chat Theme, fitur yang digunakan untuk mengatur warna theme dari Chat Screen. Fitur ini juga memiliki tone warna yang berbeda berdasarkan dengan Theme Aplikasi yang digunakan oleh user.

3. Contacts
    - Search Contact, fitur yang digunakan untuk mencari nomor kontak yang sudah disave berdasarkan susunan string nya, bisa berupa nama kontak yang di save ataupun susunan angka nomor tersebut.
    - Filter by Tags, fitur yang mengelompokkan nomor berdasarkan label yang sudah diberikan oleh user (Spam Likely, Trusted, dan Unknown).
    - Add Contact, fitur yang digunakan untuk menambahkan kontak baru untuk user. Terdiri dari nama kontak yang ingin kita tambahkan beserta dengan nomornya.
    - Edit Contact, fitur yang digunakan untuk mengedit informasi kontak yang sudah kita simpan.
    - Delete Contact, fitur yang digunakan untuk menghapus kontak dari database milik user.

4. Social
    - Chat Screen, fitur yang digunakan untuk melakukan interaksi chat dengan kontak lain. Fitur ini menyediakan opsi update chat untuk mengedit pesan yang sudah dikirim sebelumnya dan delete chat untuk menghapus pesan yang sudah dikirim.
    - Chat History, fitur ini berfungsi sebagai halaman tempat kontak-kontak yang sudah pernah melakukan chat dengan user berada, fitur ini akan memberikan informasi berupa nama kontak, pesan terakhir yang muncul di halaman Chat Screen, dan waktu pengiriman pesan.
    - Call, fitur ini berfungsi untuk melakukan menghubungkan user dengan kontak lain menggunakan telepon. Dimana pihak yang menerima telepon memiliki opsi untuk menerima, menolak, atau bahkan bisa saja melewatkan telepon tersebut.
    - Call History, fitur ini berfungsi untuk menyimpan log dari call yang telah dibuat. Fitur ini membagi status call menjadi beberapa status yang berbeda.

5. Protection & Safety
    - Protection Stats, fitur ini berguna untuk mengecek statistik dari tingkat keamanan user. Terdiri dari jumlah nomor yang dicek aplikasi beserta logs nya, statistik dari jumlah spam dan report yang sudah diberikan, dan report action yang berguna untuk mengkonfirmasi report pada nomor yang mencurigakan.
    - Tags, fitur ini berguna untuk memberikan nomor kontak lain sebuah label yang membedakan apakah kontak tersebut dapat dipercaya, tidak dapat dipercaya, ataupun tidak diketahui. 
    - Reports, fitur yang digunakan untuk memberikan laporan berdasarkan kategori tertentu kepada aplikasi bahwa nomor kontak tertentu berpotensi mencurigakan bagi user. Nomor yang dilaporkan akan mendapat penanda report.
    - Check My Tags, fitur yang digunakan untuk mengecek nama yang diberikan oleh user kontak lain ke akun/nomor user. Akan muncul tag nama yang diberikan, namun informasi siapa yang menyimpannya tidak akan terlihat.

6. Customer Service
    - FAQ, fitur ini menyediakan beberapa pertanyaan yang sering muncul untuk Customer Service, dimana pertanyaan-pertanyaan ini akan dibedakan berdasarkan kategori yang ada.
    - Help Center, fitur ini menyediakan form untuk menulis pertanyaan yang tidak tersedia di FAQ dan akan masuk ke dalam database.

