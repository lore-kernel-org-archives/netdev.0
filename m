From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] Fix help text
Date: Tue, 21 Sep 2004 17:15:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921.171517.213149358.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Documentation/networking/tulip.txt is referred even though it is
unavailable.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== drivers/net/tulip/Kconfig 1.11 vs edited =====
--- 1.11/drivers/net/tulip/Kconfig	2004-06-05 00:16:07 +09:00
+++ edited/drivers/net/tulip/Kconfig	2004-09-21 17:05:00 +09:00
@@ -40,9 +40,7 @@
 	  (smc9332dst), you can also try the driver for "Generic DECchip"
 	  cards, above.  However, most people with a network card of this type
 	  will say Y here.) Do read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  More specific
-	  information is contained in 
-	  <file:Documentation/networking/tulip.txt>.
+	  <http://www.tldp.org/docs.html#howto>.
 
 	  To compile this driver as a module, choose M here and read
 	  <file:Documentation/networking/net-modules.txt>.  The module will

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
