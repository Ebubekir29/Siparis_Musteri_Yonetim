*&---------------------------------------------------------------------*
*&  Include           ZMRT_MANAGE_ORDERS_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_EMAIL .
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

*    LOOP AT GT_ALVTABLE into GS_ALVTABLE.
      GV_CONTENT = GV_CONTENT
   && '  <tr>                                '
   && '     <td> ' &&  gs_alvtable-VBELN  && ' </td> '
   && '     <td> ' &&  gs_alvtable-MAKTX  && ' </td> '
   && '     <td> ' &&  gs_alvtable-NAME1  && ' </td> '
   && '     <td> ' &&  gs_alvtable-ERDAT_EXT  && ' </td> '
   && '     <td> ' &&  gs_alvtable-KWMENG && ' </td> '
   && '     <td> ' &&  gs_alvtable-NETWR  && ' </td> '
   && '     <td> ' &&  gs_alvtable-TOPLAM_TUTAR  && ' </td> '
   && '     <td> ' &&  gs_alvtable-STATUS && ' </td> '
   && '   </tr>                              '.
*    ENDLOOP.
    gv_content = gv_content && '</table>                              '
    && '</body>                               '
    && '</html>                               '.

    GT_SOLI = CL_DOCUMENT_BCS=>STRING_TO_SOLI( IP_STRING = GV_CONTENT ).

    call METHOD go_gbt->SET_MAIN_HTML
      exporting
        CONTENT = GT_SOLI.
IF GS_ALVTABLE-STATUS = 'ONAYLANDI'.
  GO_DOC_BCS = CL_DOCUMENT_BCS=>CREATE_FROM_MULTIRELATED(
                     I_SUBJECT          = 'Siparisiniz oluşturuldu'
                     I_MULTIREL_SERVICE =  GO_GBT
                 ).
  ELSEIF GS_ALVTABLE-STATUS = 'IPTAL'.
  GO_DOC_BCS = CL_DOCUMENT_BCS=>CREATE_FROM_MULTIRELATED(
                     I_SUBJECT          = 'Siparisiniz Iptal edildi.'
                     I_MULTIREL_SERVICE =  GO_GBT
                 ).
ENDIF.

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

ENDFORM.
