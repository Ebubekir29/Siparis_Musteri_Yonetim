*&---------------------------------------------------------------------*
*&  Include           ZMRT_MANAGE_ORDERS_MDL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
go_main->pbo_0100( ).
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
go_main->pai_0100( iv_ucomm = sy-ucomm ).
ENDMODULE.