*&---------------------------------------------------------------------*
*&  Include           ZMRT_ORDER_MANAGMENT_S_TOP
*&---------------------------------------------------------------------*

CLASS LCL_CLASS  DEFINITION DEFERRED.
CLASS lcl_class2 DEFINITION DEFERRED.

  TABLES: zmrt_kna1.


" Müsteri Top
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

PARAMETERS: rb_mus RADIOBUTTON GROUP rb1 USER-COMMAND us1,
            rb_order RADIOBUTTON GROUP rb1,
            rb_mysip RADIOBUTTON GROUP rb1.


"Siparis Top

CONTROLS TB_ID TYPE TABSTRIP.

DATA: GO_MAIN2    TYPE REF TO LCL_CLASS2,
*      go_cont     type REF TO CL_GUI_CUSTOM_CONTAINER,
*      go_grid     type REF TO cl_gui_alv_grid,
      go_cont_sip type REF TO cl_gui_custom_container,
      go_grid_sip TYPE REF TO cl_gui_alv_grid.

*data: gt_fcat type LVC_T_FCAT,
*      GS_FCAT TYPE LVC_S_FCAT,
*      GS_LAYO TYPE LVC_S_LAYO.

data: gt_fcat_sip type LVC_T_FCAT,
      GS_FCAT_sip TYPE LVC_S_FCAT,
      GS_LAYO_sip TYPE LVC_S_LAYO.

TYPES: BEGIN OF GTT_ALVTABLE,
         NAME1        TYPE NAME1_GP,
         vbeln        TYPE vbeln,
         erdat        TYPE erdat,
         netwr        TYPE netwr,
         MAKTX        TYPE MAKTX,
         KWMENG       TYPE KWMENG,
         STATUS       TYPE ZMRT_STATUS,
         KUNNR        TYPE KUNNR,
         MATNR        TYPE MATNR,
         SMTP_ADDR    TYPE ZMRT_EPOSTA,
         toplam_tutar TYPE Z5TOPTUT,
       END OF GTT_ALVTABLE.

DATA: gt_zvbak    TYPE TABLE OF ZMRT_ORDERS,
      gs_zvbak    TYPE ZMRT_ORDERS,
      GTT_ZORDER  TYPE TABLE OF ZMRT_ORDERS,
      GSS_ZORDER  TYPE ZMRT_ORDERS,
      GT_ALVTABLE TYPE TABLE OF GTT_ALVTABLE,
      GS_ALVTABLE TYPE GTT_ALVTABLE,
      gt_alv_sip  type TABLE OF gtt_alvtable,
      gs_alv_sip  type gtt_alvtable.

DATA: GV_MUS_NO  TYPE KUNNR,
      GV_SIP_NO  TYPE VBELN,
      gv_urun_no type matnr,
      GV_TES_TAR TYPE ERDAT,
      gv_miktar  TYPE KWMENG,
*      GV_SIP_TUR TYPE AUART,
      GV_SIP_TTR TYPE NETWR.

data: gv_sip type vbeln.
