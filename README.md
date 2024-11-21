# Siparis Müsteri Yönetim Projesi
Bu proje Sap Abap ile geliştirilmiştir. Bu projede müşteri işlemleri, sipariş işlemleri yapılmıştır. Müşterilerin görüntülenmesi ve Siparişlerin 
görüntülenmesi OO-ALV ile gerceklestirilmiştir. Siparis olusturulduktan sonra siparişin onaylanması icin zmrt_manage_orders programıyla siparislerin
yönetilmesi geceklestirilmistir. Siparis onaylanırsa veya reddedilirse siparis veren kullanıcıya mail gönderilir. Gönderilen mail de Smartforms ile 
yapılmış fatura pdf şeklinde gönderilmiştir. Projede kullanılan veriler Sap veritabanına kaydedilmiştir.
# Müşteri İşlemleri Sekmesi
Müşteri işlemleri sekmesinde müsteri olusturlabilir,düzenlenebilir veya müsteri silinebilir. OO-ALV 'deki Excele Kaydet butonuyla müsteriler 
toplu bir sekilde Excele kaydedilebilmektedir. Excelden Müsteri Ekle butonu ile toplu olarak müsterileri Sap'ye ekleme işlemleri gerceklestirilebilmektedir.

<img width="833" alt="ad" src="https://github.com/user-attachments/assets/9806284c-9c96-4129-bcaa-629a2c0ecd7b">

# Siparis İslemleri Sekmesi
Siparis islemleri sekmesinde siparis olusturulabilir,düzenlenebilir veya siparis silinebilir. Search help ile veriler otomatik getirilebilmektedir.

<img width="788" alt="xssx" src="https://github.com/user-attachments/assets/b1b1d151-681e-49a1-89ce-b1f52e70ab32">


# Siparislerim Sekmesi

Siparislerim sekmesinde müsteri numarısı search help ile girilip Siparislerim butonuna basıldıgında OO-ALV DE müsterinin verdigi siparisler listelenir.
Siparislerin durumuna göre (iptal,beklemede,onaylandı) renklendirme yapılmıştır.

<img width="611" alt="ede" src="https://github.com/user-attachments/assets/65e1c8cc-75ab-4d33-b592-858f6bd57ae7">
<img width="412" alt="ee" src="https://github.com/user-attachments/assets/03634305-f82e-4bbc-a47d-e686d541883b">

# Fatura 
Smartforms ile siparis faturası oluşturulmuştur.

<img width="451" alt="Ekran görüntüsü 2024-11-21 172044" src="https://github.com/user-attachments/assets/ec2d57fc-ab7b-4573-a7e9-23a5cecb3aa7">

