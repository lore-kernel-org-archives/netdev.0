From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 2/3 2.4] e1000: Update to Configure.help
Date: Fri, 15 Oct 2004 06:49:48 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150506380.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp old/linux-2.4/Documentation/Configure.help new/linux-2.4/Documentation/Configure.help
--- old/linux-2.4/Documentation/Configure.help	2004-10-07 15:33:24.000000000 -0700
+++ new/linux-2.4/Documentation/Configure.help	2004-10-07 15:33:53.000000000 -0700
@@ -12219,28 +12219,7 @@ CONFIG_E100
 Intel(R) PRO/1000 Gigabit Ethernet support
 CONFIG_E1000
   This driver supports Intel(R) PRO/1000 gigabit ethernet family of
-  adapters, which includes:
-
-     Controller  Adapter Name                         Board IDs
-     ----------  ------------                         ---------
-     82542       PRO/1000 Gigabit Server Adapter      700262-xxx,
-                                                      717037-xxx
-     82543       PRO/1000 F Server Adapter            738640-xxx,
-                                                      A38888-xxx
-     82543       PRO/1000 T Server Adapter            A19845-xxx,
-                                                      A33948-xxx
-     82544       PRO/1000 XT Server Adapter           A51580-xxx
-     82544       PRO/1000 XF Server Adapter           A50484-xxx
-     82544       PRO/1000 T Desktop Adapter           A62947-xxx
-     82540       PRO/1000 MT Desktop Adapter          A78408-xxx
-     82541       PRO/1000 MT Desktop Adapter          C91016-xxx
-     82545       PRO/1000 MT Server Adapter           A92165-xxx
-     82546       PRO/1000 MT Dual Port Server Adapter A92111-xxx
-     82545       PRO/1000 MF Server Adapter           A91622-xxx
-     82545       PRO/1000 MF Server Adapter(LX)       A91624-xxx
-     82546       PRO/1000 MF Dual Port Server Adapter A91620-xxx 
-
-  For more information on how to identify your adapter, go to the
+  adapters. For more information on how to identify your adapter, go to the
   Adapter & Driver ID Guide at:
 
    <http://support.intel.com/support/network/adapter/pro100/21397.htm>
