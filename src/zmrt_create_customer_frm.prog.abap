*&---------------------------------------------------------------------*
*&  Include           ZMRT_CREATE_CUSTOMER_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_EMAIL .
  matcher = cl_abap_matcher=>create(
             pattern = `\w+(\.\w+)*@(\w+\.)+(\w{2,4})`
             ignore_case = 'X'
             text = GV_EMAIL ).
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_TEL_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_TEL_NUMBER .
  IF strlen( GV_TELEFON ) < 10 OR strlen( GV_TELEFON ) > 15.
    message 'Geçersiz telefon numarası! Lütfen dogru telefon numarası giriniz.' TYPE 'I'.
  ENDIF.
ENDFORM.

MODULE f4_request_customer INPUT.

  data: gt_return_tab type TABLE OF DDSHRETVAL,
        gt_mapping    type TABLE OF dselc,
        gs_mapping    type dselc.

*        SELECT KUNNR,NAME1,STCD1,LAND1,ORT01,STRAS,TELF1,SMTP_ADDR
*        from zmrt_kna1
*        into CORRESPONDING FIELDS OF TABLE @gt_musteri
*        WHERE KUNNR = @GV_CUST_NO.

  sort GT_MUSTERI.
  delete adjacent duplicates from GT_MUSTERI.

  GS_MAPPING-FLDNAME   = 'F0002'.
  GS_MAPPING-DYFLDNAME = 'GV_CUST_NO'.
  APPEND GS_MAPPING TO GT_MAPPING.

  GS_MAPPING-FLDNAME   = 'F0003'.
  GS_MAPPING-DYFLDNAME = 'GV_NAME'.
  APPEND GS_MAPPING TO GT_MAPPING.

  GS_MAPPING-FLDNAME   = 'F0004'.
  GS_MAPPING-DYFLDNAME = 'GV_TAX_NO'.
  APPEND GS_MAPPING TO GT_MAPPING.

  GS_MAPPING-FLDNAME   = 'F0005'.
  GS_MAPPING-DYFLDNAME = 'GV_ULKE'.
  APPEND GS_MAPPING TO GT_MAPPING.

  GS_MAPPING-FLDNAME   = 'F0006'.
  GS_MAPPING-DYFLDNAME = 'GV_SEHIR'.
  APPEND GS_MAPPING TO GT_MAPPING.

  GS_MAPPING-FLDNAME   = 'F0007'.
  GS_MAPPING-DYFLDNAME = 'GV_SOKAK'.
  APPEND GS_MAPPING TO GT_MAPPING.

  GS_MAPPING-FLDNAME   = 'F0008'.
  GS_MAPPING-DYFLDNAME = 'GV_TELEFON'.
  APPEND GS_MAPPING TO GT_MAPPING.

  GS_MAPPING-FLDNAME   = 'F0009'.
  GS_MAPPING-DYFLDNAME = 'GV_EMAIL'.
  APPEND GS_MAPPING TO GT_MAPPING.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'KUNNR'
      DYNPPROG        = sy-repid
      DYNPNR          = sy-DYNNR
      DYNPROFIELD     = 'GV_CUST_NO'
      VALUE_ORG       = 'S'
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = GT_MUSTERI
      RETURN_TAB      = gt_return_tab
      DYNPFLD_MAPPING = gt_mapping.

  LOOP AT SCREEN.
    IF screen-name = 'GV_CUST_NO'.
      screen-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
endmodule.
*&---------------------------------------------------------------------*
*&      Form  CLEAR_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR_TEXT .
            clear: GV_CUST_NO.
            clear: GV_NAME.
            clear: GV_TAX_NO.
            clear: GV_ULKE.
            clear: GV_SEHIR.
            clear: GV_SOKAK.
            clear: GV_EMAIL.
            clear: GV_TELEFON.
ENDFORM.
