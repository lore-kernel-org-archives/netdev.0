From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] SCTP: typo in Kconfig
Date: Sat, 16 Aug 2003 05:33:32 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030816.053332.108341697.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This patch fixes typo in net/sctp/Kconfig.

Thanks in advance.

Index: linux-2.6/net/sctp/Kconfig
===================================================================
RCS file: /home/cvs/linux-2.5/net/sctp/Kconfig,v
retrieving revision 1.6
diff -u -r1.6 Kconfig
--- linux-2.6/net/sctp/Kconfig	10 May 2003 12:19:24 -0000	1.6
+++ linux-2.6/net/sctp/Kconfig	15 Aug 2003 19:01:23 -0000
@@ -43,7 +43,7 @@
 	bool "SCTP: Use old checksum (Adler-32)"
 	depends on IP_SCTP
 	help
-	  RCF2960 currently specifies the Adler-32 checksum algorithm for SCTP.
+	  RFC2960 currently specifies the Adler-32 checksum algorithm for SCTP.
 	  This has been deprecated and replaced by an algorithm now referred
 	  to as crc32c.
 


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
