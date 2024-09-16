*&---------------------------------------------------------------------*
*&  Include           ZMRT_CREATE_CUSTOMER_CLS
*&---------------------------------------------------------------------*

CLASS LCL_CLASS DEFINITION.
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
      display_alv.
ENDCLASS.

CLASS LCL_CLASS IMPLEMENTATION.
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
*    data: gt_return_tab type TABLE OF DDSHRETVAL,
*          gt_mapping type TABLE OF dselc,
*          gs_mapping type dselc.
*
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD               = 'KUNNR'
*     DYNPPROG                = sy-repid
*     DYNPNR                  = sy-DYNNR
*     DYNPROFIELD             = 'GV_CUST_NO'
*     VALUE_ORG               = 'S'
*    TABLES
*      VALUE_TAB              = GT_MUSTERI
*     RETURN_TAB              = gt_return_tab
*     DYNPFLD_MAPPING         =
.
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

*    IF GV_CUST_NO is not INITIAL.
*      SELECT KUNNR,NAME1,STCD1,LAND1,ORT01,STRAS,TELF1,SMTP_ADDR
*        from zmrt_kna1
*        into CORRESPONDING FIELDS OF TABLE @gt_musteri
*        WHERE KUNNR = @GV_CUST_NO.
*      SORT GT_MUSTERI ASCENDING BY KUNNR.
*      LOOP AT gt_musteri into gs_musteri.
*        GV_CUST_NO  = GS_MUSTERI-KUNNR.
*        GV_NAME     = GS_MUSTERI-NAME1.
*        GV_EMAIL    = GS_MUSTERI-SMTP_ADDR.
*        GV_SEHIR    = GS_MUSTERI-ORT01.
*        GV_SOKAK    = GS_MUSTERI-STRAS.
*        GV_TAX_NO   = GS_MUSTERI-STCD1.
*        GV_TELEFON  = GS_MUSTERI-TELF1.
*        GV_ULKE     = GS_MUSTERI-LAND1.
*        MODIFY SCREEN.
*      ENDLOOP.
**        Gs_MUSTERI-name1 = zmrt_kna1-name1.
**        MODIFY SCREEN.
*    ENDIF.
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
    ENDCASE.
  ENDMETHOD.
  METHOD GET_DATA.
*      SELECT KUNNR,NAME1,STCD1,LAND1,ORT01,STRAS,TELF1,SMTP_ADDR
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
*        CALL SCREEN 0200.
      ELSE.
        message 'Müşteri Oluşturulamadı.Tekrar deneyin.' type 'I'.
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
*      CALL SCREEN 0200.
    ELSE.
      message 'Müşteri güncellenemedi.Tekrar deneyin.' type 'I'.
    ENDIF.
  ENDMETHOD.
  METHOD DELETE_CUST.
    DELETE FROM ZMRT_KNA1 WHERE KUNNR = @GV_CUST_NO.
    IF sy-SUBRC = 0.
      MESSAGE 'Müşteri başarılı bir şekilde silindi.' type 'I'.
*      CALL SCREEN 0200.
    ELSE.
      message 'Müşteri silinemedi.Tekrar deneyin.' type 'I'.
    ENDIF.
  ENDMETHOD.
  METHOD set_fcat.
*    CLEAR gs_fcat.
*    gs_fcat-REF_TABLE = 'ZMRT_KNA1'.
*    gs_fcat-REF_FIELD = 'MANDT'.
*    gs_fcat-FIELDNAME = 'MANDT'.
*    gs_fcat-SCRTEXT_S = 'Müşteri N.'.
*    gs_fcat-SCRTEXT_M = 'Müşteri No.'.
*    gs_fcat-SCRTEXT_L = 'Müşteri No.'.
*    append gs_fcat to gt_fcat.
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
            lv_musteri_no  TYPE string,
            lv_musteri_adi TYPE string,
            lv_email       TYPE string,
            lv_telefon     TYPE string,
            lv_ulke        TYPE string,
            lv_sehir       TYPE string,
            lv_sokak       TYPE string,
            lv_vergiNo     TYPE string,
*            lv_filename    TYPE string,
            lv_path        TYPE string,
            lv_fullpath    TYPE string,
            lv_user_action TYPE i.


      call method CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
        exporting
*         WINDOW_TITLE        =     " Window Title
*         DEFAULT_EXTENSION   =     " Default Extension
*         DEFAULT_FILE_NAME   =     " Default File Name
*         WITH_ENCODING       =
*         FILE_FILTER         =     " File Type Filter Table
*         INITIAL_DIRECTORY   =     " Initial Directory
          PROMPT_ON_OVERWRITE = 'X'
        changing
          filename            = lv_filename
          path                = lv_path
          fullpath            = lv_fullpath
          user_action         = lv_user_action.
      .

*      lv_filename = 'C:\Users\MRT\Downloads\ornek31.xls'.

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
