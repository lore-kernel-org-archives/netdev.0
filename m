From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV4: CONFIG_INET description
Date: Tue, 28 Oct 2003 23:34:43 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028.233443.26373361.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Description of CONFIG_INET seems out-of-date.

===== net/Kconfig 1.26 vs edited =====
--- 1.26/net/Kconfig	Sun Oct  5 15:50:47 2003
+++ edited/net/Kconfig	Tue Oct 28 23:24:10 2003
@@ -96,14 +96,8 @@
 	  allows you to ping yourself (great fun, that!).
 
 	  For an excellent introduction to Linux networking, please read the
-	  NET-3-HOWTO, available from
+	  Linux Networking HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
-
-	  This option is also necessary if you want to use the full power of
-	  term (term is a program which gives you almost full Internet
-	  connectivity if you have a regular dial up shell account on some
-	  Internet connected Unix computer; for more information, read
-	  <http://www.bart.nl/~patrickr/term-howto/Term-HOWTO.html>).
 
 	  If you say Y here and also to "/proc file system support" and
 	  "Sysctl support" below, you can change various aspects of the

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
