From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 2.4 1/2] e100: Update to Configure.help
Date: Mon, 18 Oct 2004 03:22:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410180247420.20965-100000@isotope.jf.intel.com>
References: <Pine.LNX.4.44.0410150504480.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>,
        Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0410150504480.31227-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -Nuarp old/Documentation/Configure.help new/Documentation/Configure.help
--- old/Documentation/Configure.help	2004-10-07 15:33:24.000000000 -0700
+++ new/Documentation/Configure.help	2004-10-07 15:33:53.000000000 -0700
@@ -12192,65 +12192,16 @@ CONFIG_DL2K
 
 EtherExpress Pro/100 support (e100, Alternate Intel driver)
 CONFIG_E100
-  This driver supports Intel(R) PRO/100 family of adapters, which
-  includes:
-
-     Controller  Adapter Name                       Board IDs
-     ----------  ------------                       ---------
-
-     82558       PRO/100+ PCI Adapter               668081-xxx,
-                                                    689661-xxx
-     82558       PRO/100+ Management Adapter        691334-xxx,
-                                                    701738-xxx,
-                                                    721383-xxx
-     82558       PRO/100+ Dual Port Server Adapter  714303-xxx,
-                                                    711269-xxx,
-                                                    A28276-xxx
-     82558       PRO/100+ PCI Server Adapter        710550-xxx
-     82550       PRO/100 S Server Adapter           752438-xxx
-     82559                                          A56831-xxx,
-                                                    A10563-xxx,
-                                                    A12171-xxx,
-                                                    A12321-xxx,
-                                                    A12320-xxx,
-                                                    A12170-xxx
-                                                    748568-xxx
-                                                    748565-xxx
-     82550       PRO/100 S Desktop Adapter          751767-xxx
-     82559                                          748592-xxx,
-                                                    A12167-xxx,
-                                                    A12318-xxx,
-                                                    A12317-xxx,
-                                                    A12165-xxx,
-                                                    748569-xxx
-     82559       PRO/100+ Server Adapter            729757-xxx
-     82559       PRO/100 S Management Adapter       748566-xxx,
-                                                    748564-xxx
-     82550       PRO/100 S Dual Port Server Adapter A56831-xxx
-     82551       PRO/100 M Desktop Adapter          A80897-xxx
-                 PRO/100 S Advanced Management Adapter
-                                                    747842-xxx,
-                                                    745171-xxx
-     CNR         PRO/100 VE Desktop Adapter         A10386-xxx,
-                                                    A10725-xxx,
-                                                    A23801-xxx,
-                                                    A19716-xxx
-                 PRO/100 VM Desktop Adapter         A14323-xxx,
-                                                    A19725-xxx,
-                                                    A23801-xxx,
-                                                    A22220-xxx,
-                                                    A23796-xxx
-
-
+  This driver supports Intel(R) PRO/100 family of adapters.
   To verify that your adapter is supported, find the board ID number
   on the adapter. Look for a label that has a barcode and a number
-  in the format 123456-001 (six digits hyphen three digits). Match
-  this to the list of numbers above.
+  in the format 123456-001 (six digits hyphen three digits).
 
-  For more information on how to identify your adapter, go to the
-  Adapter & Driver ID Guide at:
+  Use the above information and the Adapter & Driver ID Guide at:
 
-    http://support.intel.com/support/network/adapter/pro100/21397.htm
+  http://support.intel.com/support/network/adapter/pro100/21397.htm
+
+  to identify the adapter.
 
   For the latest Intel PRO/100 network driver for Linux, see:
 
