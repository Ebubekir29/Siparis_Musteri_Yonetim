*&---------------------------------------------------------------------*
*&  Include           ZMRT_CREATE_ORDER_TOP
*&---------------------------------------------------------------------*

CLASS LCL_CLASS DEFINITION DEFERRED.

DATA: GO_MAIN     TYPE REF TO LCL_CLASS,
      go_cont     type REF TO CL_GUI_CUSTOM_CONTAINER,
      go_grid     type REF TO cl_gui_alv_grid,
      go_cont_sip type REF TO cl_gui_custom_container,
      go_grid_sip TYPE REF TO cl_gui_alv_grid.

data: gt_fcat type LVC_T_FCAT,
      GS_FCAT TYPE LVC_S_FCAT,
      GS_LAYO TYPE LVC_S_LAYO.

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
