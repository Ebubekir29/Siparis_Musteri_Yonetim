*&---------------------------------------------------------------------*
*&  Include           ZMRT_CREATE_CUSTOMER_TOP
*&---------------------------------------------------------------------*

CLASS LCL_CLASS DEFINITION DEFERRED.
TABLES: zmrt_kna1.
TYPES: BEGIN OF gty_kna1,
         mandt      type mandt,
         KUNNR      type KUNNR,
         NAME1      type NAME1_GP,
         STCD1      type STCD1,
         LAND1      type LAND1_GP,
         ORT01      type ORT01_GP,
         STRAS      type STRAS_GP,
         TELF1      type TELF1,
         SMTP_ADDR  TYPE ZMRT_EPOSTA,
       END OF gty_kna1.


DATA: GO_MAIN TYPE REF TO LCL_CLASS,
      go_cont type REF TO CL_GUI_CUSTOM_CONTAINER,
      go_grid type REF TO cl_gui_alv_grid.

data: gt_fcat type LVC_T_FCAT,
      GS_FCAT TYPE LVC_S_FCAT,
      GS_LAYO TYPE LVC_S_LAYO.

DATA: gt_musteri type TABLE OF ZMRT_KNA1,
      gs_musteri TYPE ZMRT_KNA1.


DATA: GV_CUST_NO TYPE ZMRT_KNA1-KUNNR,
      GV_NAME    TYPE ZMRT_KNA1-NAME1,
      GV_TAX_NO  TYPE ZMRT_KNA1-STCD1,
      GV_ULKE    TYPE ZMRT_KNA1-LAND1,
      GV_SEHIR   TYPE ZMRT_KNA1-ORT01,
      GV_SOKAK   TYPE ZMRT_KNA1-STRAS,
      GV_EMAIL   TYPE ZMRT_KNA1-SMTP_ADDR,
      GV_TELEFON TYPE ZMRT_KNA1-TELF1.

DATA matcher TYPE REF TO cl_abap_matcher.
