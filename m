From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] DECNET: Compaq => HP
Date: Wed, 29 Oct 2003 01:09:33 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031029.010933.21400721.yoshfuji@linux-ipv6.org>
References: <20031029.004659.91579816.yoshfuji@linux-ipv6.org>
	<20031028075747.23ea54b8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031028075747.23ea54b8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031028075747.23ea54b8.davem@redhat.com> (at Tue, 28 Oct 2003 07:57:47 -0800), "David S. Miller" <davem@redhat.com> says:

> On Wed, 29 Oct 2003 00:46:59 +0900 (JST)
> YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:
> 
> > More document update: Compaq was bought by HP...
> 
> I think it's more appropriate to mention both Compaq and
> HP, right?

How about this?

===== net/Kconfig 1.26 vs edited =====
--- 1.26/net/Kconfig	Sun Oct  5 15:50:47 2003
+++ edited/net/Kconfig	Wed Oct 29 01:07:54 2003
@@ -145,9 +145,9 @@
 	tristate "DECnet Support"
 	---help---
 	  The DECnet networking protocol was used in many products made by
-	  Digital (now Compaq).  It provides reliable stream and sequenced
-	  packet communications over which run a variety of services similar
-	  to those which run over TCP/IP.
+	  Digital (bought by Compaq, and now HP).  It provides reliable 
+	  stream and sequenced packet communications over which run a 
+	  variety of services similar to those which run over TCP/IP.
 
 	  To find some tools to use with the kernel layer support, please
 	  look at Patrick Caulfield's web site:


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
