From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Fw: [PATCH] Kill unneeded version.h from net/sched
Date: Wed, 3 Sep 2003 08:30:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903083005.5a35c59f.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart_Wed__3_Sep_2003_08:30:05_-0700_09378280"
Cc: felipewd@terra.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart_Wed__3_Sep_2003_08:30:05_-0700_09378280
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


Another net/ patch.
~Randy


Begin forwarded message:

Date: Wed, 03 Sep 2003 11:29:44 -0300
From: Felipe W Damasio <felipewd@terra.com.br>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: [PATCH] Kill unneeded version.h from net/sched


	Hi,

	Last patch, removing all references that checkversion gave me on net/

	Against 2.6-test4, please apply.

	Cheers

Felipe

--Multipart_Wed__3_Sep_2003_08:30:05_-0700_09378280
Content-Type: text/plain;
 name="net_sched-checkversion.patch"
Content-Disposition: attachment;
 filename="net_sched-checkversion.patch"
Content-Transfer-Encoding: 7bit

--- linux-2.6.0-test4/net/sched/sch_htb.c	Fri Aug 22 20:57:14 2003
+++ linux-2.6.0-test4-fwd/net/sched/sch_htb.c	Wed Sep  3 11:27:06 2003
@@ -32,7 +32,6 @@
 #include <asm/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/mm.h>


--Multipart_Wed__3_Sep_2003_08:30:05_-0700_09378280--
