*&---------------------------------------------------------------------*
*&  Include           ZMRT_ORDER_MANAGMENT_S_CLS
*&---------------------------------------------------------------------*

CLASS lcl_class DEFINITION.
  PUBLIC SECTION.

    METHODS:
      START_SCREEN,
      PBO_0100,
      PAI_0100 IMPORTING IV_UCOMM TYPE SY-UCOMM,
      pbo_0200,
      PAI_0200 IMPORTING IV_UCOMM TYPE SY-UCOMM,
      GET_DATA,
      create_cust,
      edit_cust,
      delete_cust,
      set_fcat,
      set_layout,
      HANDLE_TOOLBAR FOR EVENT toolbar of cl_gui_alv_grid
        IMPORTING
            E_OBJECT
            E_INTERACTIVE,
      send_excel FOR EVENT user_command of cl_gui_alv_grid
        IMPORTING
            E_UCOMM,
      batch_input FOR EVENT user_command of cl_gui_alv_grid
        IMPORTING
            E_UCOMM,
      display_alv.
endclass.

CLASS lcl_class2 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      start_screen,
      pbo_0200,
      pai_0200 IMPORTING iv_ucomm TYPE sy-UCOMM,
      get_data,
      ADD_ORDER,
      edit_order,
      delete_order,
      set_fcat,
      set_layout,
      HANDLE_TOOLBAR FOR EVENT toolbar of cl_gui_alv_grid
        IMPORTING
            E_OBJECT
            E_INTERACTIVE,
      send_excel FOR EVENT user_command of cl_gui_alv_grid
        IMPORTING
            E_UCOMM,
      send_mail,
      display_alv,
      pbo_0300,
      pai_0300 IMPORTING iv_ucomm TYPE sy-UCOMM,
      get_mysip,
      get_sipris,
      set_fcat_sip,
      set_layout_sip,
      disp_alv_sip.
ENDCLASS.

class lcl_class IMPLEMENTATION.
  METHOD START_SCREEN.
    CALL  SCREEN 0100.
  ENDMETHOD.
  METHOD PBO_0100.
    SET PF-STATUS '0100'.
    SET TITLEBAR 'Müşteri Düzenle'.
    GO_MAIN->GET_DATA( ).
    go_main->set_fcat( ).
    go_main->SET_LAYOUT( ).
    go_main->DISPLAY_ALV( ).
  ENDMETHOD.
  METHOD PAI_0100.
    CASE iv_ucomm.
      WHEN '&BACK'.
        LEAVE TO SCREEN 0.
      when '&CRT'.
        GO_MAIN->CREATE_CUST( ).
      when '&SAVE'.
        GO_MAIN->EDIT_CUST( ).
      when '&DLT'.
        GO_MAIN->DELETE_CUST( ).
    ENDCASE.
  ENDMETHOD.
  METHOD PBO_0200.
    SET PF-STATUS '0200'.
    SET TITLEBAR 'Müşteriler'.
    GO_MAIN->GET_DATA( ).
    go_main->set_fcat( ).
    go_main->SET_LAYOUT( ).
    go_main->DISPLAY_ALV( ).
  ENDMETHOD.
  METHOD PAI_0200.
    CASE iv_ucomm.
      WHEN '&BACK'.
        LEAVE TO SCREEN 0.
      when '&batch'.
        GO_MAIN->BATCH_INPUT( ).
    ENDCASE.
  ENDMETHOD.
  METHOD GET_DATA.
    SELECT *
      FROM ZMRT_KNA1 INTO CORRESPONDING FIELDS OF TABLE GT_MUSTERI.
  ENDMETHOD.
  method CREATE_CUST.
    IF  GV_CUST_NO IS INITIAL
    and GV_ULKE    IS INITIAL
    and GV_EMAIL   IS INITIAL
    and GV_SEHIR   IS INITIAL
    and GV_SOKAK   IS INITIAL
    and GV_TAX_NO  IS INITIAL
    and GV_TELEFON IS INITIAL
    and GV_NAME    IS INITIAL.
      MESSAGE 'Lütfen tüm alanları doldurunuz.' type 'I'.
    else.
      perform check_tel_number.
      PERFORM validate_email.

      IF matcher->match( ) is INITIAL.
        MESSAGE 'Email Formatını yanlıs girdiniz.' TYPE 'I'.
      ELSE.
        GS_MUSTERI-KUNNR     = GV_CUST_NO.
        GS_MUSTERI-NAME1     = GV_NAME.
        GS_MUSTERI-STCD1     = GV_TAX_NO.
        GS_MUSTERI-LAND1     = GV_ULKE.
        GS_MUSTERI-ORT01     = GV_SEHIR.
        GS_MUSTERI-STRAS     = GV_SOKAK.
        GS_MUSTERI-SMTP_ADDR = GV_EMAIL.
        GS_MUSTERI-TELF1     = GV_TELEFON.
        Insert ZMRT_KNA1 from GS_MUSTERI.
        IF sy-SUBRC = 0.
          MESSAGE 'Müşteri başarılı bir şekilde oluşturuldu.' type 'I'.
          perform clear_text.
        ELSE.
          message 'Müşteri Oluşturulamadı.Tekrar deneyin.' type 'I'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  method EDIT_CUST.

    GS_MUSTERI-NAME1     = GV_NAME.
    GS_MUSTERI-STCD1     = GV_TAX_NO.
    GS_MUSTERI-LAND1     = GV_ULKE.
    GS_MUSTERI-ORT01     = GV_SEHIR.
    GS_MUSTERI-STRAS     = GV_SOKAK.
    GS_MUSTERI-SMTP_ADDR = GV_EMAIL.
    GS_MUSTERI-TELF1     = GV_TELEFON.
    UPDATE ZMRT_KNA1 set NAME1 = @GV_NAME, LAND1 = @GV_ULKE, ORT01 = @GV_SEHIR, STCD1 = @GV_TAX_NO,
                         STRAS = @GV_SOKAK, TELF1 = @GV_TELEFON, SMTP_ADDR = @GV_EMAIL
                      WHERE kunnr = @GV_CUST_NO.
    IF sy-SUBRC = 0.
      MESSAGE 'Müşteri başarılı bir şekilde güncellendi.' type 'I'.
      perform clear_text.
    ELSE.
      message 'Müşteri güncellenemedi.Tekrar deneyin.' type 'I'.
    ENDIF.
  ENDMETHOD.
  METHOD DELETE_CUST.
    DELETE FROM ZMRT_KNA1 WHERE KUNNR = @GV_CUST_NO.
    IF sy-SUBRC = 0.
      MESSAGE 'Müşteri başarılı bir şekilde silindi.' type 'I'.
      perform clear_text.
    ELSE.
      message 'Müşteri silinemedi.Tekrar deneyin.' type 'I'.
    ENDIF.
  ENDMETHOD.
  METHOD set_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
    gs_fcat-REF_FIELD = 'KUNNR'.
    gs_fcat-FIELDNAME = 'KUNNR'.
    gs_fcat-SCRTEXT_S = 'Müşteri N.'.
    gs_fcat-SCRTEXT_M = 'Müşteri No.'.
    gs_fcat-SCRTEXT_L = 'Müşteri No.'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
    gs_fcat-REF_FIELD = 'NAME1'.
    gs_fcat-FIELDNAME = 'NAME1'.
    gs_fcat-SCRTEXT_S = 'Müşteri A.'.
    gs_fcat-SCRTEXT_M = 'Müşteri Adı.'.
    gs_fcat-SCRTEXT_L = 'Müşteri Adı.'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
    gs_fcat-REF_FIELD = 'SMTP_ADDR'.
    gs_fcat-FIELDNAME = 'SMTP_ADDR'.
    gs_fcat-SCRTEXT_S = 'Email'.
    gs_fcat-SCRTEXT_M = 'Email'.
    gs_fcat-SCRTEXT_L = 'Email'.
    gs_fcat-F4AVAILABL = 'X'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
    gs_fcat-REF_FIELD = 'TELF1'.
    gs_fcat-FIELDNAME = 'TELF1'.
    gs_fcat-SCRTEXT_S = 'Telefon No'.
    gs_fcat-SCRTEXT_M = 'Telefon No.'.
    gs_fcat-SCRTEXT_L = 'Telefon No.'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
    gs_fcat-REF_FIELD = 'LAND1'.
    gs_fcat-FIELDNAME = 'LAND1'.
    gs_fcat-SCRTEXT_S = 'Ulke'.
    gs_fcat-SCRTEXT_M = 'Ulke'.
    gs_fcat-SCRTEXT_L = 'Ulke'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
    gs_fcat-REF_FIELD = 'ORT01'.
    gs_fcat-FIELDNAME = 'ORT01'.
    gs_fcat-SCRTEXT_S = 'Sehir'.
    gs_fcat-SCRTEXT_M = 'Sehir'.
    gs_fcat-SCRTEXT_L = 'Sehir'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
    gs_fcat-REF_FIELD = 'STRAS'.
    gs_fcat-FIELDNAME = 'STRAS'.
    gs_fcat-SCRTEXT_S = 'Sokak'.
    gs_fcat-SCRTEXT_M = 'Sokak'.
    gs_fcat-SCRTEXT_L = 'Sokak'.
    append gs_fcat to gt_fcat.
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
    gs_fcat-REF_FIELD = 'STCD1'.
    gs_fcat-FIELDNAME = 'STCD1'.
    gs_fcat-SCRTEXT_S = 'Vergi No'.
    gs_fcat-SCRTEXT_M = 'Vergi No'.
    gs_fcat-SCRTEXT_L = 'Vergi No'.
    append gs_fcat to gt_fcat.
  ENDMETHOD.
  METHOD set_layout.
    GS_LAYO-COL_OPT    = 'X'.
    GS_LAYO-CWIDTH_OPT = 'X'.
    GS_LAYO-ZEBRA      = 'X'.
  ENDMETHOD.
  METHOD HANDLE_TOOLBAR.
    data: ls_toolbar TYPE STB_BUTTON.
    CLEAR: ls_toolbar.
    LS_TOOLBAR-TEXT      = 'Excele Kaydet'.
    LS_TOOLBAR-FUNCTION  = '&KYDT'.
    LS_TOOLBAR-QUICKINFO = 'Excele Kaydet'.
    LS_TOOLBAR-ICON = '@2V@'.
    append ls_toolbar to E_OBJECT->MT_TOOLBAR.

    CLEAR: ls_toolbar.
    LS_TOOLBAR-TEXT      = 'Excelden Müsteri Ekle'.
    LS_TOOLBAR-FUNCTION  = '&add'.
    LS_TOOLBAR-QUICKINFO = 'Excelden Müsteri Ekle'.
    LS_TOOLBAR-ICON = '@2L@'.
    append ls_toolbar to E_OBJECT->MT_TOOLBAR.
  ENDMETHOD.
  METHOD send_excel.
    IF E_UCOMM = '&KYDT'.
      DATA: lt_fieldcat    TYPE lvc_t_fcat,
            lv_filename    TYPE string,
            lt_excel_data  TYPE TABLE OF string,
            ls_excel_row   TYPE string,
            lv_line        TYPE string,
            lv_musteri_no  TYPE string,
            lv_musteri_adi TYPE string,
            lv_email       TYPE string,
            lv_telefon     TYPE string,
            lv_ulke        TYPE string,
            lv_sehir       TYPE string,
            lv_sokak       TYPE string,
            lv_vergiNo     TYPE string,
            lv_path        TYPE string,
            lv_fullpath    TYPE string,
            lv_user_action TYPE i.

      call method CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
        exporting
*         WINDOW_TITLE        = ''
          DEFAULT_EXTENSION   = '.xls'
          DEFAULT_FILE_NAME   = 'ornek'
          PROMPT_ON_OVERWRITE = 'X'
        changing
          filename            = lv_filename
          path                = lv_path
          fullpath            = lv_fullpath
          user_action         = lv_user_action.
      .

      CONCATENATE 'Musteri No' 'Müsteri Adı' 'Email' 'Telefon' 'Ulke' 'Sehir' 'Sokak' 'Vergi No'
                  INTO lv_line SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
      APPEND lv_line TO lt_excel_data.

      LOOP AT GT_MUSTERI INTO GS_MUSTERI.
        lv_musteri_no   = gs_musteri-KUNNR.
        lv_musteri_adi  = gs_musteri-NAME1.
        lv_email        = gs_musteri-SMTP_ADDR.
        lv_telefon      = gs_musteri-TELF1.
        lv_ulke         = gs_musteri-LAND1.
        lv_sehir        = gs_musteri-ORT01.
        lv_sokak        = gs_musteri-STRAS.
        lv_vergiNo      = gs_musteri-STCD1.

        CONCATENATE lv_musteri_no lv_musteri_adi lv_email lv_telefon lv_ulke lv_sehir lv_sokak lv_vergiNo
         INTO lv_line SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
        APPEND lv_line TO lt_excel_data.
      ENDLOOP.

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename              = lv_fullpath
          filetype              = 'ASC'
          write_field_separator = 'X'
        TABLES
          data_tab              = lt_excel_data
        EXCEPTIONS
          others                = 1.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        MESSAGE 'Excel dosyasına aktarma başarılı' TYPE 'I'.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  method batch_input.
    IF e_ucomm = '&add'.
      DATA: it_excel      TYPE TABLE OF alsmex_tabline,
            lv_file       TYPE rlgrap-filename,
            lt_file_table type FILETABLE,
            lv_patch      type string,
            LV_RC         TYPE I.

      call method CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
        changing
          FILE_TABLE              = lt_file_table
          RC                      = LV_RC
        exceptions
          FILE_OPEN_DIALOG_FAILED = 1
          CNTL_ERROR              = 2
          ERROR_NO_GUI            = 3
          NOT_SUPPORTED_BY_GUI    = 4
          OTHERS                  = 5.

      IF lv_rc = 1 AND lt_file_table IS NOT INITIAL.
        READ TABLE lt_file_table INTO DATA(ls_file) INDEX 1.
        lv_file = ls_file-filename.
      ELSE.
        MESSAGE 'Dosya seçilmedi!' TYPE 'I'.
        RETURN.
      ENDIF.

      CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
        EXPORTING
          filename                = lv_file
          i_begin_col             = 1
          i_begin_row             = 2
          i_end_col               = 8
          i_end_row               = 1000
        TABLES
          intern                  = it_excel
        EXCEPTIONS
          inconsistent_parameters = 1
          upload_ole              = 2
          OTHERS                  = 3.

      DATA: it_final TYPE TABLE OF GTY_KNA1,
            wa_final TYPE GTY_KNA1.

      LOOP AT it_excel INTO DATA(wa_excel).
        CASE wa_excel-col.
          WHEN 1.
            wa_final-kunnr = wa_excel-value.
          WHEN 2.
            wa_final-name1 = wa_excel-value.
          WHEN 3.
            wa_final-stcd1 = wa_excel-value.
          WHEN 4.
            wa_final-land1 = wa_excel-value.
          WHEN 5.
            wa_final-ort01 = wa_excel-value.
          WHEN 6.
            wa_final-stras = wa_excel-value.
          WHEN 7.
            wa_final-telf1 = wa_excel-value.
          WHEN 8.
            wa_final-smtp_addr = wa_excel-value.
        ENDCASE.

        IF wa_excel-col = 8.
          INSERT zmrt_kna1 FROM wa_final.
          CLEAR wa_final.
        ENDIF.
      ENDLOOP.
      IF sy-subrc = 0.
        message: 'Veri başarıyla eklendi: ' TYPE 'I'.
        call METHOD GO_MAIN->GET_DATA.
        call METHOD GO_GRID->REFRESH_TABLE_DISPLAY( ).
      ELSE.
        MESSAGE: 'Veri eklenirken hata oluştu: ' type 'I'.
      ENDIF.
    ENDIF.
  endmethod.
  METHOD display_alv.
    IF GO_GRID is INITIAL .
      CREATE OBJECT GO_CONT
        exporting
          CONTAINER_NAME = 'CC_ALV'.
      create OBJECT GO_GRID
        exporting
          I_PARENT = go_cont.

      create OBJECT go_main.
      set HANDLER GO_MAIN->HANDLE_TOOLBAR for go_grid.
      set HANDLER GO_MAIN->SEND_EXCEL     for go_grid.
      set HANDLER GO_MAIN->batch_input    for go_grid.

      go_grid->SET_TABLE_FOR_FIRST_DISPLAY(
        exporting
          IS_LAYOUT                     =  GS_LAYO
        changing
          IT_OUTTAB                     =  GT_MUSTERI
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

CLASS lcl_class2 IMPLEMENTATION.
  METHOD start_screen.
    CALL SCREEN 0200.
  ENDMETHOD.
  METHOD pbo_0200.
    SET PF-STATUS '0200'.
  ENDMETHOD.
  METHOD pai_0200.
    CASE IV_UCOMM.
      WHEN '&BACK'.
        LEAVE TO SCREEN 0.
      when '&SAVE'.
        GO_MAIN2->ADD_ORDER( ).
        GO_MAIN2->SEND_MAIL( ).
        IF sy-subrc = 0.
          MESSAGE 'Siparisiniz oluşturuldu.' TYPE 'I'.
          CLEAR: GV_MUS_NO,
                 GV_SIP_NO,
                 gv_urun_no,
                 GV_TES_TAR,
                 GV_MIKTAR,
                 GV_SIP_TTR.
        else.
          MESSAGE 'Siparisiniz oluşturulamadı. Lütfen tekrar deneyiniz.' TYPE 'I'.
        ENDIF.

*        CALL SCREEN 0200.
      when '&EDIT'.
        GO_MAIN2->EDIT_ORDER( ).
        IF sy-subrc = 0.
          MESSAGE 'Siparisiniz güncellendi.' TYPE 'I'.
        else.
          MESSAGE 'Siparisiniz güncellenemedi. Lütfen tekrar deneyiniz.' TYPE 'I'.
        ENDIF.
        CALL SCREEN 0200.
      WHEN '&DLT'.
        GO_MAIN2->DELETE_ORDER( ).
        IF sy-subrc = 0.
          MESSAGE 'Siparisiniz silindi.' TYPE 'I'.
        else.
          MESSAGE 'Siparisiniz silinemedi. Lütfen tekrar deneyiniz.' TYPE 'I'.
        ENDIF.
        CALL SCREEN 0200.
    ENDCASE.
    IF GV_SIP_NO is not INITIAL.
      SELECT orders~erdat,orders~netwr, orders~status, orders~kwmeng,orders~vbeln,orders~matnr,orders~kunnr
        from zmrt_orders as orders
        into CORRESPONDING FIELDS OF TABLE @GT_ZVBAK
        WHERE VBELN = @GV_SIP_NO.
      SORT GT_ZVBAK ASCENDING BY vbeln.
      LOOP AT GT_ZVBAK into GS_ZVBAK.
        GV_SIP_NO   = GS_ZVBAK-VBELN.
        GV_URUN_NO  = GS_ZVBAK-matnr.
        GV_MUS_NO   = GS_ZVBAK-KUNNR.
        GV_TES_TAR  = GS_ZVBAK-erdat.
        GV_MIKTAR   = GS_ZVBAK-KWMENG.
        GV_SIP_TTR  = GS_ZVBAK-NETWR.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
    IF GV_URUN_NO is not INITIAL.
      data: gt_mara type TABLE OF zmrt_mara,
            gs_mara type zmrt_mara.
      SELECT mara~maktx, mara~netwr
        from zmrt_mara as mara
        into CORRESPONDING FIELDS OF TABLE @GT_MARA
        where matnr = @GV_URUN_NO.
      SORT GT_MARA ASCENDING BY matnr.
      LOOP AT gt_mara into GS_MARA.
        GV_SIP_TTR = GS_MARA-NETWR.
        GV_URUN_NO = GS_MARA-MAKTX.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  method pbo_0300.
    SET PF-STATUS '0300'.
  endmethod.
  method pai_0300.
    CASE IV_UCOMM.
      WHEN '&BACK'.
        LEAVE TO SCREEN 0.
      WHEN '&GET_S'.
        IF GV_MUS_NO is not INITIAL.
          go_main2->GET_SIPRIS( ).
          IF GT_ALV_SIP is INITIAL.
            MESSAGE 'Musteriye ait siparis bulunamadı.' type 'I'.
          else.
            go_main2->SET_FCAT_SIP( ).
            go_main2->SET_LAYOUT_SIP( ).
            go_main2->disp_alv_sip( ).
          ENDIF.
        ELSE.
          MESSAGE 'Lütfen müsteri numarası giriniz.' TYPE 'I'.
        ENDIF.
    ENDCASE.
  endmethod.
  METHOD get_data.
    select   orders~erdat,orders~netwr, orders~status, orders~kwmeng,orders~vbeln,orders~TOPLAM_TUTAR, mara~maktx, kna1~name1
      from ZMRT_ORDERS as orders
      INNER JOIN zmrt_vbak as vbak on orders~VBELN = vbak~VBELN
      INNER JOIN zmrt_mara as mara on orders~matnr = mara~matnr
      INNER JOIN zmrt_kna1 as kna1 on orders~kunnr = kna1~kunnr
      into CORRESPONDING FIELDS OF TABLE @GT_ALVTABLE.

  ENDMETHOD.
  METHOD ADD_ORDER.
    IF     GV_SIP_NO  IS INITIAL
       AND GV_MUS_NO  IS INITIAL
       AND GV_SIP_TTR IS INITIAL
       AND GV_MIKTAR IS INITIAL
       AND GV_URUN_NO IS INITIAL
       AND GV_TES_TAR IS INITIAL.
      MESSAGE 'Lütfen tüm alanları doldurunuz.' type 'I'.
    else.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gv_urun_no
        IMPORTING
          output = gv_urun_no.
      GS_ZVBAK-KUNNR  = GV_MUS_NO.
      GS_ZVBAK-VBELN  = GV_SIP_NO.
      GS_ZVBAK-matnr  = gv_urun_no.
      GS_ZVBAK-ERDAT  = GV_TES_TAR.
      GS_ZVBAK-KWMENG = GV_MIKTAR.
      GS_ZVBAK-STATUS = 'BEKLEMEDE'.
      GS_ZVBAK-NETWR  = GV_SIP_TTR.
      GS_ZVBAK-TOPLAM_TUTAR = GV_MIKTAR * GV_SIP_TTR.
      insert ZMRT_ORDERS FROM gs_zvbak.
      IF sy-subrc = 0.
        MESSAGE 'Sipariş başarıyla oluşturuldu.' TYPE 'S'.
      ELSE.
        MESSAGE 'Sipariş oluşturulamadı.' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  method edit_order.
    IF     GV_SIP_NO  IS INITIAL
       AND GV_MUS_NO  IS INITIAL
       AND GV_SIP_TTR IS INITIAL
       AND GV_MIKTAR IS INITIAL
       AND GV_URUN_NO IS INITIAL
       AND GV_TES_TAR IS INITIAL.
      MESSAGE 'Lütfen tüm alanları doldurunuz.' type 'I'.
    else.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gv_urun_no
        IMPORTING
          output = gv_urun_no.
      GS_ZVBAK-KUNNR  = GV_MUS_NO.
      GS_ZVBAK-VBELN  = GV_SIP_NO.
      GS_ZVBAK-matnr  = gv_urun_no.
      GS_ZVBAK-ERDAT  = GV_TES_TAR.
      GS_ZVBAK-KWMENG = GV_MIKTAR.
      GS_ZVBAK-NETWR  = GV_SIP_TTR.
      GS_ZVBAK-TOPLAM_TUTAR = GV_MIKTAR * GV_SIP_TTR.
      update ZMRT_ORDERS FROM GS_ZVBAK.
      IF sy-subrc = 0.
        MESSAGE 'Sipariş başarıyla güncellendi.' TYPE 'S'.
      ELSE.
        MESSAGE 'Sipariş güncellenemedi.' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD DELETE_ORDER.
    delete from ZMRT_ORDERS where vbeln = @GV_SIP_NO.
    IF sy-SUBRC = 0.
      MESSAGE 'Sipariş başarıyla silindi.' TYPE 'S'.
    ELSE.
      MESSAGE 'Sipariş silinemedi.' TYPE 'E'.
    ENDIF.
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
    CLEAR gs_fcat.
    gs_fcat-REF_TABLE = 'zmrt_orders'.
    gs_fcat-REF_FIELD = 'ERDAT'.
    gs_fcat-FIELDNAME = 'ERDAT'.
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
    append gs_fcat to gt_fcat.
  ENDMETHOD.
  METHOD set_layout.
    GS_LAYO-COL_OPT    = 'X'.
    GS_LAYO-CWIDTH_OPT = 'X'.
    GS_LAYO-ZEBRA      = 'X'.
  ENDMETHOD.
  METHOD HANDLE_TOOLBAR.
    data: ls_toolbar TYPE STB_BUTTON.
    CLEAR: ls_toolbar.
    LS_TOOLBAR-TEXT      = 'Excele Kaydet'.
    LS_TOOLBAR-FUNCTION  = '&KYDT'.
    LS_TOOLBAR-QUICKINFO = 'Excele Kaydet'.
    LS_TOOLBAR-ICON = '@DN@'.
    append ls_toolbar to E_OBJECT->MT_TOOLBAR.
  ENDMETHOD.
  METHOD send_excel.
    IF E_UCOMM = '&KYDT'.
      DATA: lt_fieldcat    TYPE lvc_t_fcat,
            lv_filename    TYPE string,
            lt_excel_data  TYPE TABLE OF string,
            ls_excel_row   TYPE string,
            lv_line        TYPE string,
            lv_musteri_adi TYPE string,
            lv_sip_no      TYPE string,
            lv_urun_adi    TYPE string,
            lv_sip_tarih   TYPE string,
            lv_miktar      TYPE string,
            lv_fiyat       TYPE string,
            lv_durum       TYPE string,
            lv_ttl_tutar   TYPE string,
            lv_path        TYPE string,
            lv_fullpath    TYPE string,
            lv_user_action TYPE i.


      call method CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
        exporting
          DEFAULT_EXTENSION   = 'xls'
          DEFAULT_FILE_NAME   = 'ornek'
          PROMPT_ON_OVERWRITE = 'X'
        changing
          filename            = lv_filename
          path                = lv_path
          fullpath            = lv_fullpath
          user_action         = lv_user_action.
      .

      CONCATENATE 'Siparis No' 'Müsteri Adı' 'Urun Adı' 'Siparis Tarihi' 'Miktar' 'Fiyat' 'Toplam Tutar' 'Durum'
                  INTO lv_line SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
      APPEND lv_line TO lt_excel_data.

      LOOP AT GT_ALVTABLE INTO GS_ALVTABLE.
        lv_musteri_adi  = gs_alvtable-NAME1.
        lv_sip_no       = gs_alvtable-VBELN.
        LV_URUN_ADI     = gs_alvtable-MAKTX.
        lv_sip_tarih    = gs_alvtable-ERDAT.
        lv_miktar       = gs_alvtable-KWMENG.
        lv_fiyat        = gs_alvtable-NETWR.
        lv_durum        = gs_alvtable-STATUS.
        lv_ttl_tutar    = gs_alvtable-TOPLAM_TUTAR.

        CONCATENATE lv_musteri_adi lv_sip_no LV_URUN_ADI lv_sip_tarih lv_miktar lv_fiyat lv_durum lv_ttl_tutar
         INTO lv_line SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
        APPEND lv_line TO lt_excel_data.
      ENDLOOP.


      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename              = lv_fullpath
          filetype              = 'ASC'
          write_field_separator = 'X'
        TABLES
          data_tab              = lt_excel_data
        EXCEPTIONS
          others                = 1.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        MESSAGE 'Excel dosyasına aktarma başarılı' TYPE 'I'.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD send_mail.

    DATA: lo_bcs         TYPE REF TO cl_bcs,
          lo_doc_bcs     TYPE REF TO cl_document_bcs,
          lo_recep       TYPE REF TO if_recipient_bcs,
          lo_sapuser_bcs TYPE REF TO cl_sapuser_bcs,
          lo_cx_bcx      TYPE REF TO cx_bcs.

    DATA: lt_otfdata        TYPE ssfcrescl,
          lt_binary_content TYPE solix_tab,
          lt_text           TYPE bcsy_text,
          lt_pdf_tab        TYPE STANDARD TABLE OF tline,
          lt_otf            TYPE STANDARD TABLE OF itcoo.

    DATA: ls_ctrlop TYPE ssfctrlop,
          ls_outopt TYPE ssfcompop.

    DATA: lv_bin_filesize TYPE so_obj_len,
          lv_sent_to_all  TYPE os_boolean,
          lv_bin_xstr     TYPE xstring,
          lv_fname        TYPE rs38l_fnam,
          lv_string_text  TYPE string.

    SELECT * FROM ZMRT_ORDERS
         INTO CORRESPONDING FIELDS OF TABLE @GTT_ZORDER
               WHERE KUNNR = @GV_MUS_NO
               and   MATNR = @GV_URUN_NO
               and   VBELN = @GV_SIP_NO.

    select   orders~erdat,orders~netwr, orders~status, orders~kwmeng,orders~vbeln,orders~TOPLAM_TUTAR, mara~maktx, kna1~name1
    ,kna1~SMTP_ADDR
        from ZMRT_ORDERS as orders
        INNER JOIN zmrt_mara as mara on orders~matnr = mara~matnr
        INNER JOIN zmrt_kna1 as kna1 on orders~kunnr = kna1~kunnr
        into CORRESPONDING FIELDS OF TABLE @GT_ALVTABLE
         WHERE ORDERS~KUNNR = @GV_MUS_NO
         and   orders~MATNR = @GV_URUN_NO
         and   orders~VBELN = @GV_SIP_NO.

    READ TABLE GT_ALVTABLE INTO GS_ALVTABLE INDEX 1.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            FORMNAME           = 'ZMRT_SIPARIS_DD'
          IMPORTING
            FM_NAME            = lv_fname
          EXCEPTIONS
            NO_FORM            = 1
            NO_FUNCTION_MODULE = 2
            OTHERS             = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    ls_ctrlop-getotf = 'X'.
    ls_ctrlop-no_dialog = 'X'.
    ls_ctrlop-preview = space.

    ls_outopt-tdnoprev = 'X'.
    ls_outopt-tddest = 'LP01'.
    ls_outopt-tdnoprint = 'X'.

    DATA: l_devtype TYPE rspoptype.

    CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
      EXPORTING
        i_language             = 'E'
      IMPORTING
        e_devtype              = l_devtype
      EXCEPTIONS
        no_language            = 1
        language_not_installed = 2
        no_devtype_found       = 3
        system_error           = 4
        OTHERS                 = 5.

    ls_outopt-tdprinter = l_devtype.

    CALL FUNCTION lv_fname
      EXPORTING
        control_parameters = ls_ctrlop
        output_options     = ls_outopt
      IMPORTING
        job_output_info    = lt_otfdata
      TABLES
        orders             = GTT_ZORDER
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    lt_otf[] = lt_otfdata-otfdata[].
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
      IMPORTING
        bin_filesize          = lv_bin_filesize
        bin_file              = lv_bin_xstr
      TABLES
        otf                   = lt_otf[]
        lines                 = lt_pdf_tab[]
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lv_bin_xstr
      TABLES
        binary_tab = lt_binary_content.


    TRY.
        lo_bcs = cl_bcs=>create_persistent( ).

        CONCATENATE:  'Merhaba  ' CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB GS_ALVTABLE-NAME1 cl_abap_char_utilities=>newline INTO lv_string_text.
        APPEND lv_string_text TO lt_text.
        CLEAR lv_string_text.

        CONCATENATE 'Siparisiniz basarılı bir sekilde olusturulmustur. Ekte siparis detaylarını görebilirsiniz.'
        cl_abap_char_utilities=>newline INTO lv_string_text.
        APPEND lv_string_text TO lt_text.
        CLEAR lv_string_text.

        APPEND 'Iyi Günler,' TO lt_text.

        lo_doc_bcs = cl_document_bcs=>create_document(
        i_type = 'RAW'
        i_text = lt_text[]
        i_subject = 'Siparisiniz Oluşturuldu.' ).

        CALL METHOD lo_doc_bcs->add_attachment
          EXPORTING
            i_attachment_type    = 'PDF'
            i_attachment_size    = lv_bin_filesize
            i_attachment_subject = 'Siparisiniz.'
            i_att_content_hex    = lt_binary_content.

        CALL METHOD lo_bcs->set_document( lo_doc_bcs ).

        lo_recep = cl_cam_address_bcs=>create_internet_address( GS_ALVTABLE-SMTP_ADDR ).

        CALL METHOD lo_bcs->add_recipient
          EXPORTING
            i_recipient = lo_recep
            i_express   = 'X'.

        CALL METHOD lo_bcs->set_send_immediately
          EXPORTING
            i_send_immediately = 'X'.

        CALL METHOD lo_bcs->send(
          EXPORTING
            i_with_error_screen = 'X'
          RECEIVING
            result              = lv_sent_to_all ).

        IF lv_sent_to_all IS NOT INITIAL.
          COMMIT WORK.
        ENDIF.

      CATCH cx_bcs INTO lo_cx_bcx.
        WRITE: 'Exception:', lo_cx_bcx->error_type.
    ENDTRY.

  endmethod.

  METHOD display_alv.
    IF GO_GRID is INITIAL .
      CREATE OBJECT GO_CONT
        exporting
          CONTAINER_NAME = 'CC_ALV'.
      create OBJECT GO_GRID
        exporting
          I_PARENT = go_cont.

      create OBJECT go_main.
      set HANDLER GO_MAIN->HANDLE_TOOLBAR for go_grid.
      set HANDLER GO_MAIN->SEND_EXCEL     for go_grid.

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
  METHOD GET_MYSIP.
    call SCREEN 0300.
  endmethod.
  METHOD GET_SIPRIS.
    select   orders~erdat,orders~netwr, orders~status, orders~kwmeng,orders~vbeln,orders~TOPLAM_TUTAR, mara~maktx, kna1~name1
      from ZMRT_ORDERS as orders
      INNER JOIN zmrt_mara as mara on orders~matnr = mara~matnr
      INNER JOIN zmrt_kna1 as kna1 on orders~kunnr = kna1~kunnr
      into CORRESPONDING FIELDS OF TABLE @GT_ALV_SIP
      where orders~KUNNR = @GV_MUS_NO.
  endmethod.
  method set_fcat_sip.
    CLEAR GS_FCAT_SIP.
    GS_FCAT_SIP-REF_TABLE = 'zmrt_orders'.
    GS_FCAT_SIP-REF_FIELD = 'VBELN'.
    GS_FCAT_SIP-FIELDNAME = 'VBELN'.
    GS_FCAT_SIP-SCRTEXT_S = 'Siparis N.'.
    GS_FCAT_SIP-SCRTEXT_M = 'Siparis No'.
    GS_FCAT_SIP-SCRTEXT_L = 'Siparis No'.
    append GS_FCAT_SIP to GT_FCAT_SIP.
    CLEAR GS_FCAT_SIP.
    GS_FCAT_SIP-REF_TABLE = 'zmrt_orders'.
    GS_FCAT_SIP-REF_FIELD = 'NAME1'.
    GS_FCAT_SIP-FIELDNAME = 'NAME1'.
    GS_FCAT_SIP-SCRTEXT_S = 'Müşteri A.'.
    GS_FCAT_SIP-SCRTEXT_M = 'Müşteri Adı'.
    GS_FCAT_SIP-SCRTEXT_L = 'Müşteri Adı'.
    append GS_FCAT_SIP to GT_FCAT_SIP.
    CLEAR GS_FCAT_SIP.
    GS_FCAT_SIP-REF_TABLE = 'zmrt_orders'.
    GS_FCAT_SIP-REF_FIELD = 'MAKTX'.
    GS_FCAT_SIP-FIELDNAME = 'MAKTX'.
    GS_FCAT_SIP-SCRTEXT_S = 'Malzeme A.'.
    GS_FCAT_SIP-SCRTEXT_M = 'Malzeme Adı'.
    GS_FCAT_SIP-SCRTEXT_L = 'Malzeme Adı'.
    append GS_FCAT_SIP to GT_FCAT_SIP.
    CLEAR GS_FCAT_SIP.
    GS_FCAT_SIP-REF_TABLE = 'zmrt_orders'.
    GS_FCAT_SIP-REF_FIELD = 'ERDAT'.
    GS_FCAT_SIP-FIELDNAME = 'ERDAT'.
    GS_FCAT_SIP-SCRTEXT_S = 'Siparis T.'.
    GS_FCAT_SIP-SCRTEXT_M = 'Siparis Tarihi'.
    GS_FCAT_SIP-SCRTEXT_L = 'Siparis Tarihi'.
    append GS_FCAT_SIP to GT_FCAT_SIP.
    CLEAR GS_FCAT_SIP.
    GS_FCAT_SIP-REF_TABLE = 'zmrt_orders'.
    GS_FCAT_SIP-REF_FIELD = 'KWMENG'.
    GS_FCAT_SIP-FIELDNAME = 'KWMENG'.
    GS_FCAT_SIP-SCRTEXT_S = 'Miktar'.
    GS_FCAT_SIP-SCRTEXT_M = 'Miktar'.
    GS_FCAT_SIP-SCRTEXT_L = 'Miktar'.
    append GS_FCAT_SIP to GT_FCAT_SIP.
    CLEAR GS_FCAT_SIP.
    GS_FCAT_SIP-REF_TABLE = 'zmrt_orders'.
    GS_FCAT_SIP-REF_FIELD = 'NETWR'.
    GS_FCAT_SIP-FIELDNAME = 'NETWR'.
    GS_FCAT_SIP-SCRTEXT_S = 'Fiyat'.
    GS_FCAT_SIP-SCRTEXT_M = 'Fiyat'.
    GS_FCAT_SIP-SCRTEXT_L = 'Fiyat'.
    append GS_FCAT_SIP to GT_FCAT_SIP.
    CLEAR GS_FCAT_SIP.
    GS_FCAT_SIP-REF_TABLE = 'zmrt_orders'.
    GS_FCAT_SIP-REF_FIELD = 'TOPLAM_TUTAR'.
    GS_FCAT_SIP-FIELDNAME = 'TOPLAM_TUTAR'.
    GS_FCAT_SIP-SCRTEXT_S = 'Toplam Tutar'.
    GS_FCAT_SIP-SCRTEXT_M = 'Toplam Tutar'.
    GS_FCAT_SIP-SCRTEXT_L = 'Toplam Tutar'.
    append GS_FCAT_SIP to GT_FCAT_SIP.
    CLEAR GS_FCAT_SIP.
    GS_FCAT_SIP-REF_TABLE = 'zmrt_orders'.
    GS_FCAT_SIP-REF_FIELD = 'STATUS'.
    GS_FCAT_SIP-FIELDNAME = 'STATUS'.
    GS_FCAT_SIP-SCRTEXT_S = 'Durum'.
    GS_FCAT_SIP-SCRTEXT_M = 'Durum'.
    GS_FCAT_SIP-SCRTEXT_L = 'Durum'.
    append GS_FCAT_SIP to GT_FCAT_SIP.
  ENDMETHOD.
  METHOD set_layout_sip.
    GS_LAYO_SIP-COL_OPT    = 'X'.
    GS_LAYO_SIP-CWIDTH_OPT = 'X'.
    GS_LAYO_SIP-ZEBRA      = 'X'.
  ENDMETHOD.
  method disp_alv_sip.
    IF GO_GRID_SIP is INITIAL .
      CREATE OBJECT GO_CONT_SIP
        exporting
          CONTAINER_NAME = 'CC_ALV_GET_SIP'.
      create OBJECT GO_GRID_SIP
        exporting
          I_PARENT = GO_CONT_SIP.

      GO_GRID_SIP->SET_TABLE_FOR_FIRST_DISPLAY(
        exporting
          IS_LAYOUT                     =  GS_LAYO_SIP
        changing
          IT_OUTTAB                     =  GT_ALV_SIP
          IT_FIELDCATALOG               =  GT_FCAT_SIP  ).
      GO_GRID_SIP->REGISTER_EDIT_EVENT(
        exporting
          I_EVENT_ID =   cl_gui_alv_grid=>MC_EVT_MODIFIED
      ).
    else.
      call method GO_GRID_SIP->REFRESH_TABLE_DISPLAY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
