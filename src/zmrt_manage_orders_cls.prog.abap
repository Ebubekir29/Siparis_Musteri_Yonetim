*&---------------------------------------------------------------------*
*&  Include           ZMRT_MANAGE_ORDERS_CLS
*&---------------------------------------------------------------------*

CLASS LCL_CLASS DEFINITION.
  PUBLIC SECTION.
    METHODS:
      START_SCREEN,
      PBO_0100,
      PAI_0100 IMPORTING IV_UCOMM TYPE SY-UCOMM,
      GET_DATA,
      handle_status FOR EVENT onf4 of CL_GUI_ALV_GRID
        IMPORTING
            E_FIELDNAME
            E_FIELDVALUE
            ES_ROW_NO
            ER_EVENT_DATA
            ET_BAD_CELLS
            E_DISPLAY,
      set_fcat,
      set_layout,
      display_alv.
ENDCLASS.

CLASS LCL_CLASS IMPLEMENTATION.

  METHOD START_SCREEN.
    CALL  SCREEN 0100.
  ENDMETHOD.
  METHOD PBO_0100.
    SET PF-STATUS '0100'.
    go_main->GET_DATA( ).
    go_main->set_fcat( ).
    go_main->SET_LAYOUT( ).
    go_main->DISPLAY_ALV( ).
  ENDMETHOD.
  METHOD PAI_0100.
    CASE IV_UCOMM.
      WHEN '&BACK'.
        LEAVE TO SCREEN 0.
      WHEN '&SAVE'.
        go_main->HANDLE_STATUS( ).
    ENDCASE.
  ENDMETHOD.
  METHOD get_data.
    select   orders~erdat,orders~netwr, orders~status, orders~kwmeng,orders~vbeln,orders~TOPLAM_TUTAR, mara~maktx, kna1~name1, KNA1~SMTP_ADDR
      from ZMRT_ORDERS as orders
      INNER JOIN zmrt_mara as mara on orders~matnr = mara~matnr
      INNER JOIN zmrt_kna1 as kna1 on orders~kunnr = kna1~kunnr
      into CORRESPONDING FIELDS OF TABLE @GT_ALVTABLE.
  ENDMETHOD.
  method handle_status.
    DATA: lv_row   TYPE i,
          lv_col   TYPE i,
          lv_value TYPE ZMRT_STATUS.

    call METHOD GO_grid->GET_CURRENT_CELL
      importing
        E_ROW   = lv_row
        E_VALUE = lv_value
        E_COL   = lv_col.

    READ TABLE GT_ALVTABLE INTO GS_ALVTABLE index LV_ROW.
    IF sy-subrc = 0.
      GS_ALVTABLE-STATUS = lv_value.

      UPDATE ZMRT_ORDERS SET STATUS = GS_ALVTABLE-STATUS
        WHERE VBELN = GS_ALVTABLE-VBELN.

      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE 'Veri başarıyla güncellendi.' TYPE 'S'.
      ELSE.
        MESSAGE 'Güncelleme hatası oluştu.' TYPE 'E'.
      ENDIF.
    ENDIF.

     PERFORM SEND_EMAIL.

  endmethod.
  METHOD set_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'VBELN'.
    gs_fcat-FIELDNAME = 'VBELN'.
    gs_fcat-SCRTEXT_S = 'Siparis N.'.
    gs_fcat-SCRTEXT_M = 'Siparis No'.
    gs_fcat-SCRTEXT_L = 'Siparis No'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'NAME1'.
    gs_fcat-FIELDNAME = 'NAME1'.
    gs_fcat-SCRTEXT_S = 'Müşteri A.'.
    gs_fcat-SCRTEXT_M = 'Müşteri Adı'.
    gs_fcat-SCRTEXT_L = 'Müşteri Adı'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'MAKTX'.
    gs_fcat-FIELDNAME = 'MAKTX'.
    gs_fcat-SCRTEXT_S = 'Malzeme A.'.
    gs_fcat-SCRTEXT_M = 'Malzeme Adı'.
    gs_fcat-SCRTEXT_L = 'Malzeme Adı'.
    append gs_fcat to gt_fcat.
    LOOP AT gt_alvtable INTO DATA(ls_alv).
      IF ls_alv-ERDAT IS NOT INITIAL.
        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
          EXPORTING
            DATE_INTERNAL = ls_alv-ERDAT
          IMPORTING
            DATE_EXTERNAL = ls_alv-ERDAT_EXT.
      ENDIF.
      MODIFY gt_alvtable FROM ls_alv.
    ENDLOOP.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'ERDAT_EXT'.
    gs_fcat-FIELDNAME = 'ERDAT_EXT'.
    gs_fcat-SCRTEXT_S = 'Siparis T.'.
    gs_fcat-SCRTEXT_M = 'Siparis Tarihi'.
    gs_fcat-SCRTEXT_L = 'Siparis Tarihi'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'KWMENG'.
    gs_fcat-FIELDNAME = 'KWMENG'.
    gs_fcat-SCRTEXT_S = 'Miktar'.
    gs_fcat-SCRTEXT_M = 'Miktar'.
    gs_fcat-SCRTEXT_L = 'Miktar'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'NETWR'.
    gs_fcat-FIELDNAME = 'NETWR'.
    gs_fcat-SCRTEXT_S = 'Fiyat'.
    gs_fcat-SCRTEXT_M = 'Fiyat'.
    gs_fcat-SCRTEXT_L = 'Fiyat'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'TOPLAM_TUTAR'.
    gs_fcat-FIELDNAME = 'TOPLAM_TUTAR'.
    gs_fcat-SCRTEXT_S = 'Toplam Tutar'.
    gs_fcat-SCRTEXT_M = 'Toplam Tutar'.
    gs_fcat-SCRTEXT_L = 'Toplam Tutar'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'STATUS'.
    gs_fcat-FIELDNAME = 'STATUS'.
    gs_fcat-SCRTEXT_S = 'Durum'.
    gs_fcat-SCRTEXT_M = 'Durum'.
    gs_fcat-SCRTEXT_L = 'Durum'.
    gs_fcat-EDIT      = 'X'.
    append gs_fcat to gt_fcat.
  ENDMETHOD.
  METHOD set_layout.
    GS_LAYO-COL_OPT    = 'X'.
    GS_LAYO-CWIDTH_OPT = 'X'.
    GS_LAYO-ZEBRA      = 'X'.
  ENDMETHOD.
  METHOD display_alv.
    IF GO_GRID is INITIAL .
      CREATE OBJECT GO_CONT
        exporting
          CONTAINER_NAME = 'CC_ALV'.
      create OBJECT GO_GRID
        exporting
          I_PARENT = go_cont.

      CREATE OBJECT go_main.
      SET HANDLER go_main->HANDLE_STATUS FOR GO_GRID.

      go_grid->SET_TABLE_FOR_FIRST_DISPLAY(
        exporting
          IS_LAYOUT                     =  GS_LAYO
        changing
          IT_OUTTAB                     =  GT_ALVTABLE
          IT_FIELDCATALOG               =  GT_FCAT  ).
      go_grid->REGISTER_EDIT_EVENT(
        exporting
          I_EVENT_ID =   cl_gui_alv_grid=>MC_EVT_MODIFIED
      ).
    else.
      call method go_grid->REFRESH_TABLE_DISPLAY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
