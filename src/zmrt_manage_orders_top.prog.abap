*&---------------------------------------------------------------------*
*&  Include           ZMRT_MANAGE_ORDERS_TOP
*&---------------------------------------------------------------------*

CLASS LCL_CLASS DEFINITION DEFERRED.


  DATA: GO_MAIN TYPE REF TO LCL_CLASS,
        GO_GRID TYPE REF TO CL_GUI_ALV_GRID,
        GO_CONT TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

  DATA: GT_FCAT TYPE LVC_T_FCAT,
        GS_FCAT TYPE LVC_S_FCAT,
        GS_LAYO TYPE LVC_S_LAYO.

  TYPES: BEGIN OF GTT_ALVTABLE,
         NAME1        TYPE NAME1_GP,
         vbeln        TYPE vbeln,
         erdat        TYPE erdat,
         ERDAT_EXT    TYPE CHAR10,
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
      GS_ALVTABLE TYPE GTT_ALVTABLE.
