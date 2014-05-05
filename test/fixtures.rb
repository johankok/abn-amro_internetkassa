RESPONSES = {
  :succeeded => {
    "CN"         => "Buyer name",
    "BRAND"      => "iDEAL",
    "orderID"    => "1235052040",
    "PAYID"      => "3051611",
    "ACCEPTANCE" => "0000000000",
    "amount"     => "10",
    "CARDNO"     => "11-XXXX-11",
    "PM"         => "iDEAL",
    "STATUS"     => "9",
    "IP"         => "83.68.2.74",
    "TRXDATE"    => "02/19/09",
    "NCERROR"    => "0",
    "ED"         => "",
    "SHASIGN"    => "D385E7C290062CDBF121CD711F22C9EBF7A3DBC9",
    "currency"   => "EUR"
  },
  
  :failed => {
    "CN"         => "",
    "BRAND"      => "iDEAL",
    "orderID"    => "1235052641",
    "PAYID"      => "3051687",
    "ACCEPTANCE" => "",
    "amount"     => "10",
    "CARDNO"     => "",
    "PM"         => "iDEAL",
    "STATUS"     => "2",
    "IP"         => "83.68.2.74",
    "TRXDATE"    => "02/19/09",
    "NCERROR"    => "30001001",
    "ED"         => "",
    "SHASIGN"    => "0397393DD2F4BD4F6D7ED5B48F926DCDAC05A35F",
    "currency"   => "EUR"
  },
  
  :cancelled => {
    "CN" => "",
    "BRAND" => "iDEAL",
    "orderID" => "1235052559",
    "PAYID" => "3051681",
    "ACCEPTANCE" => "",
    "amount" => "10",
    "CARDNO" => "",
    "PM" => "iDEAL",
    "STATUS" => "2",
    "IP" => "83.68.2.74",
    "TRXDATE" => "02/19/09",
    "NCERROR" => "30171001",
    "ED" => "",
    "SHASIGN" => "ECECAFF55A72A2E4CE92AA39F87E948A07E8F46A",
    "currency" => "EUR"
  },
  
  :exception => {
    "CN"         => "",
    "BRAND"      => "iDEAL",
    "orderID"    => "1235052396",
    "PAYID"      => "3051657",
    "action"     => "index",
    "ACCEPTANCE" => "",
    "amount"     => "10",
    "CARDNO"     => "",
    "PM"         => "iDEAL",
    "STATUS"     => "92",
    "IP"         => "83.68.2.74",
    "TRXDATE"    => "02/19/09",
    "NCERROR"    => "20002001",
    "ED"         => "",
    "SHASIGN"    => "92AE23CE2A05676FA205883E710A79D33D60ADB3",
    "currency"   => "EUR"
  }
}