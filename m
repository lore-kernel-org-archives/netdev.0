From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 IPComp
Date: Sat, 17 May 2003 07:27:45 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030517.072745.05080928.yoshfuji@linux-ipv6.org>
References: <87llx72imk.wl@karaba.org>
	<Pine.LNX.4.44.0305170035010.22475-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mk@linux-ipv6.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@intercode.com.au,
   pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0305170035010.22475-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0305170035010.22475-100000@netcore.fi> (at Sat, 17 May 2003 00:35:43 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> > + * IP Payload Compression Protocol (IPComp) for IPv6 - RFC3713
> 
> What?!? Such RFC does not exist :-)

Oops... :-p

Index: net/ipv6/ipcomp6.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/Attic/ipcomp6.c,v
retrieving revision 1.1.2.3
retrieving revision 1.1.2.4
diff -u -r1.1.2.3 -r1.1.2.4
--- net/ipv6/ipcomp6.c	16 May 2003 10:51:00 -0000	1.1.2.3
+++ net/ipv6/ipcomp6.c	16 May 2003 22:11:25 -0000	1.1.2.4
@@ -1,5 +1,5 @@
 /*
- * IP Payload Compression Protocol (IPComp) for IPv6 - RFC3713
+ * IP Payload Compression Protocol (IPComp) for IPv6 - RFC3173
  *
  * Copyright (C)2003 USAGI/WIDE Project
  *

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
