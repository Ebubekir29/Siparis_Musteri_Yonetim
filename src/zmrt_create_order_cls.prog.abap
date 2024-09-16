*&---------------------------------------------------------------------*
*&  Include           ZMRT_CREATE_ORDER_CLS
*&---------------------------------------------------------------------*

CLASS LCL_CLASS DEFINITION.
  PUBLIC SECTION.
    METHODS:
      start_screen,
      pbo_0100,
      pai_0100 IMPORTING iv_ucomm TYPE sy-UCOMM,
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
      display_alv.
ENDCLASS.


CLASS LCL_CLASS IMPLEMENTATION.
  METHOD start_screen.
    CALL SCREEN 0100.
  ENDMETHOD.
  METHOD pbo_0100.
    SET PF-STATUS '0100'.
  ENDMETHOD.
  METHOD pai_0100.
    CASE IV_UCOMM.
      WHEN '&BACK'.
        LEAVE TO SCREEN 0.
      when '&SAVE'.
        GO_MAIN->ADD_ORDER( ).
        GO_MAIN->SEND_MAIL( ).
        CALL SCREEN 0200.
      when '&EDIT'.
        GO_MAIN->EDIT_ORDER( ).
        CALL SCREEN 0200.
      WHEN '&DLT'.
        GO_MAIN->DELETE_ORDER( ).
        CALL SCREEN 0200.
    ENDCASE.
    IF GV_SIP_NO is not INITIAL.
      SELECT orders~erdat,orders~netwr, orders~status, orders~kwmeng,orders~vbeln,orders~matnr,orders~kunnr
*      SELECT *
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
        GV_STATUS   = GS_ZVBAK-STATUS.
        MODIFY SCREEN.
      ENDLOOP.
*        Gs_MUSTERI-name1 = zmrt_kna1-name1.
*        MODIFY SCREEN.
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
*        Gs_MUSTERI-name1 = zmrt_kna1-name1.
*        MODIFY SCREEN.
    ENDIF.
  ENDMETHOD.
  method pbo_0200.
    SET PF-STATUS '0200'.
    go_main->GET_DATA( ).
    go_main->set_fcat( ).
    go_main->SET_LAYOUT( ).
    go_main->DISPLAY_ALV( ).
  endmethod.
  method pai_0200.
    CASE IV_UCOMM.
      WHEN '&BACK'.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDMETHOD.
  METHOD get_data.
*    SELECT VBAK~KUNNR,VBAK~VBELN,vbak~erdat,VBAK~NETWR, vbak~status,
*        MARA~MAKTX,vbap~KWMENG
*        from ZMRT_VBAK AS VBAK
*      INNER JOIN ZMRT_MARA AS MARA ON VBAK~MATNR = MARA~MATNR
*      INNER JOIN zmrt_vbap as vbap on vbak~VBELN  = vbap~vbeln
*       INTO  TABLE @GT_ZVBAK
*       where  vbak~VBELN = @GV_SIP_NO.
    select   orders~erdat,orders~netwr, orders~status, orders~kwmeng,orders~vbeln,orders~TOPLAM_TUTAR, mara~maktx, kna1~name1
*    select   *
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
       AND GV_STATUS IS INITIAL
       AND GV_URUN_NO IS INITIAL
       AND GV_TES_TAR IS INITIAL.
      MESSAGE 'Lütfen tüm alanları doldurunuz.' type 'I'.
    else.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gv_urun_no
        IMPORTING
          output = gv_urun_no.
*      LOOP AT GT_ZVBAK INTO GS_ZVBAK.
      GS_ZVBAK-KUNNR  = GV_MUS_NO.
      GS_ZVBAK-VBELN  = GV_SIP_NO.
      GS_ZVBAK-matnr  = gv_urun_no.
      GS_ZVBAK-ERDAT  = GV_TES_TAR.
      GS_ZVBAK-KWMENG = GV_MIKTAR.
      GS_ZVBAK-STATUS = GV_STATUS.
      GS_ZVBAK-NETWR  = GV_SIP_TTR.
      GS_ZVBAK-TOPLAM_TUTAR = GV_MIKTAR * GV_SIP_TTR.

*      ENDLOOP.
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
       AND GV_STATUS IS INITIAL
       AND GV_URUN_NO IS INITIAL
       AND GV_TES_TAR IS INITIAL.
      MESSAGE 'Lütfen tüm alanları doldurunuz.' type 'I'.
    else.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gv_urun_no
        IMPORTING
          output = gv_urun_no.
*      LOOP AT GT_ZVBAK INTO GS_ZVBAK.
      GS_ZVBAK-KUNNR  = GV_MUS_NO.
      GS_ZVBAK-VBELN  = GV_SIP_NO.
      GS_ZVBAK-matnr  = gv_urun_no.
      GS_ZVBAK-ERDAT  = GV_TES_TAR.
      GS_ZVBAK-KWMENG = GV_MIKTAR.
      GS_ZVBAK-STATUS = GV_STATUS.
      GS_ZVBAK-NETWR  = GV_SIP_TTR.
      GS_ZVBAK-TOPLAM_TUTAR = GV_MIKTAR * GV_SIP_TTR.
*      ENDLOOP.

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
*         WINDOW_TITLE        =     " Window Title
          DEFAULT_EXTENSION   = 'xls'
          DEFAULT_FILE_NAME   = 'ornek'
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
    DATA : go_gbt       TYPE REF TO cl_gbt_multirelated_service,
           go_bcs       TYPE REF TO cl_bcs,
           go_doc_bcs   TYPE REF TO cl_document_bcs,
           go_recipient TYPE REF TO if_recipient_bcs,
           gt_soli      TYPE TABLE OF soli,
           gs_soli      TYPE soli,
           gv_status    TYPE bcs_rqst,
           LT_TEXT      TYPE BCSY_TEXT,
           gv_content   TYPE string.
    DATA: LV_BIN_FILESIZE TYPE SO_OBJ_LEN,
          LV_SENT_TO_ALL  TYPE OS_BOOLEAN,
          LV_BIN_XSTR     TYPE XSTRING,
          LV_FNAME        TYPE RS38L_FNAM,
          LV_STRING_TEXT  TYPE STRING.
    DATA: LT_OTFDATA        TYPE SSFCRESCL,
          LT_BINARY_CONTENT TYPE SOLIX_TAB,
          LT_PDF_TAB        TYPE STANDARD TABLE OF TLINE,
          LT_OTF            TYPE STANDARD TABLE OF ITCOO.
    create object GO_GBT.

    go_bcs = cl_bcs=>create_persistent( ).

*      catch CX_SEND_REQ_BCS.    " .
*    select count(*) from mara
*      into @DATA(gv_lines).

    select   orders~erdat,orders~netwr, orders~status, orders~kwmeng,orders~vbeln,orders~TOPLAM_TUTAR, mara~maktx, kna1~name1
      ,kna1~SMTP_ADDR
          from ZMRT_ORDERS as orders
*          INNER JOIN zmrt_vbak as vbak on orders~VBELN = vbak~VBELN
          INNER JOIN zmrt_mara as mara on orders~matnr = mara~matnr
          INNER JOIN zmrt_kna1 as kna1 on orders~kunnr = kna1~kunnr
          into CORRESPONDING FIELDS OF TABLE @GT_ALVTABLE
           WHERE ORDERS~KUNNR = @GV_MUS_NO
           and   orders~MATNR = @GV_URUN_NO
           and   orders~VBELN = @GV_SIP_NO.

*;Mail Hos
    select SINGLE mus~SMTP_ADDR from ZMRT_KNA1 as mus
      INNER JOIN ZMRT_orders as ord on mus~KUNNR eq ord~KUNNR
      into  @data(lt_email)
      where mus~KUNNR = @GV_MUS_NO.

    gv_content = '<!DOCTYPE html>                        '
           && '<html>                                '
           && '<head>                                '
           && '<meta charset="utf-8">                '
           && ' <style>                              '
           && ' th {                                 '
           && '  background-color: red;              '
           && '      border : 2px solid powderblue;  '
           && '    }                                 '
           && ' td {                                 '
           && '  background-color: yellow;           '
           && '      border : 1px solidpowderblue;   '
           && '    }                                 '
           && ' </style>                             '
           && '</head>                               '
           && '<body>                                '
           && '<table>                               '
           && '<tr>                                  '
           && '  <th>Siparis No</th>                 '
           && '  <th>Malzeme Adı</th>                '
           && '  <th>Müsteri Adı</th>                '
           && '  <th>Siparis Tarihi</th>             '
           && '  <th>Miktar</th>                     '
           && '  <th>Fiyat</th>                      '
           && '  <th>Toplam Fiyat</th>               '
           && '  <th>Durum</th>                      '
           && '</tr>                                 '.

    LOOP AT GT_ALVTABLE into GS_ALVTABLE.
      GV_CONTENT = GV_CONTENT
   && '  <tr>                                '
   && '     <td> ' &&  gs_alvtable-VBELN  && ' </td> '
   && '     <td> ' &&  gs_alvtable-MAKTX  && ' </td> '
   && '     <td> ' &&  gs_alvtable-NAME1  && ' </td> '
   && '     <td> ' &&  gs_alvtable-ERDAT  && ' </td> '
   && '     <td> ' &&  gs_alvtable-KWMENG && ' </td> '
   && '     <td> ' &&  gs_alvtable-NETWR  && ' </td> '
   && '     <td> ' &&  gs_alvtable-TOPLAM_TUTAR  && ' </td> '
   && '     <td> ' &&  gs_alvtable-STATUS && ' </td> '
   && '   </tr>                              '.
    ENDLOOP.
    gv_content = gv_content && '</table>                              '
    && '</body>                               '
    && '</html>                               '.

*    GO_DOC_BCS = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
*                I_TYPE    = 'HTM'
*                I_TEXT    = LT_TEXT[]
*                I_LENGTH  = '12'
*                I_SUBJECT = 'Siparis Olusturuldu.' ).
*
*    CALL METHOD go_bcs->SET_DOCUMENT( GO_DOC_BCS ).
*
*    go_recipient = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
*                                      I_ADDRESS_STRING = lt_email ).
*
*    CALL METHOD GO_DOC_BCS->ADD_ATTACHMENT
*      EXPORTING
*        I_ATTACHMENT_TYPE    = 'PDF'
*        I_ATTACHMENT_SIZE    = LV_BIN_FILESIZE
*        I_ATTACHMENT_SUBJECT = 'Siparisiniz'
*        I_ATT_CONTENT_HEX    = LT_BINARY_CONTENT.
*
*    CALL METHOD go_bcs->ADD_RECIPIENT
*      EXPORTING
*        I_RECIPIENT = go_recipient
*        I_EXPRESS   = 'X'.
*
*    CALL METHOD go_bcs->SET_SEND_IMMEDIATELY
*      EXPORTING
*        I_SEND_IMMEDIATELY = 'X'.
*
*    CALL METHOD go_bcs->SEND(
*      EXPORTING
*        I_WITH_ERROR_SCREEN = 'X'
*      RECEIVING
*        RESULT              = LV_SENT_TO_ALL ).
*
*    IF LV_SENT_TO_ALL IS NOT INITIAL.
*      COMMIT WORK.
*    ENDIF.

    GT_SOLI = CL_DOCUMENT_BCS=>STRING_TO_SOLI( IP_STRING = GV_CONTENT ).

    call METHOD go_gbt->SET_MAIN_HTML
      exporting
        CONTENT = GT_SOLI.

    GO_DOC_BCS = CL_DOCUMENT_BCS=>CREATE_FROM_MULTIRELATED(
                     I_SUBJECT          = 'Siparisiniz oluşturuldu'
                     I_MULTIREL_SERVICE =  GO_GBT
                 ).
    GO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                       I_ADDRESS_STRING = GS_ALVTABLE-SMTP_ADDR
                  ).

    go_bcs = CL_BCS=>CREATE_PERSISTENT( ).
    go_bcs->SET_DOCUMENT( I_DOCUMENT = GO_DOC_BCS ).
    GO_BCS->ADD_RECIPIENT( I_RECIPIENT = GO_RECIPIENT ).


    GV_STATUS = 'N'.
    call METHOD GO_BCS->SET_STATUS_ATTRIBUTES
      exporting
        I_REQUESTED_STATUS = GV_STATUS.

    GO_BCS->SEND( ).
    commit WORK.

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
ENDCLASS.
