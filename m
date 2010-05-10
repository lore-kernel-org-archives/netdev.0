From: kaber@trash.net
Subject: [PATCH 11/84] netfilter: update my email address
Date: Mon, 10 May 2010 22:17:42 +0200
Message-ID: <1273522735-24672-12-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54512 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756660Ab0EJUS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:18:59 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 Documentation/feature-removal-schedule.txt |    2 +-
 net/bridge/netfilter/ebt_ip6.c             |    2 +-
 net/netfilter/xt_TCPOPTSTRIP.c             |    3 +--
 net/netfilter/xt_connlimit.c               |    1 -
 net/netfilter/xt_connmark.c                |    2 +-
 net/netfilter/xt_hashlimit.c               |    2 +-
 net/netfilter/xt_recent.c                  |    2 +-
 net/netfilter/xt_time.c                    |    3 +--
 net/netfilter/xt_u32.c                     |    3 +--
 9 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation=
/feature-removal-schedule.txt
index 8843fef..fa327f6 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -247,7 +247,7 @@ What (Why):
=20
 When:	January 2009 or Linux 2.7.0, whichever comes first
 Why:	Superseded by newer revisions or modules
-Who:	Jan Engelhardt <jengelh@computergmbh.de>
+Who:	Jan Engelhardt <jengelh@medozas.de>
=20
 ---------------------------
=20
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_=
ip6.c
index bbf2534..4cb60f1 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -4,7 +4,7 @@
  *	Authors:
  *	Manohar Castelino <manohar.r.castelino@intel.com>
  *	Kuo-Lang Tseng <kuo-lang.tseng@intel.com>
- *	Jan Engelhardt <jengelh@computergmbh.de>
+ *	Jan Engelhardt <jengelh@medozas.de>
  *
  * Summary:
  * This is just a modification of the IPv4 code written by
diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTST=
RIP.c
index 9dd8c8e..e8b5760 100644
--- a/net/netfilter/xt_TCPOPTSTRIP.c
+++ b/net/netfilter/xt_TCPOPTSTRIP.c
@@ -3,7 +3,6 @@
  *
  * Copyright (C) 2007 Sven Schnelle <svens@bitebene.org>
  * Copyright =C2=A9 CC Computer Consultants GmbH, 2007
- * Contact: Jan Engelhardt <jengelh@computergmbh.de>
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License version 2 as
@@ -136,7 +135,7 @@ static void __exit tcpoptstrip_tg_exit(void)
=20
 module_init(tcpoptstrip_tg_init);
 module_exit(tcpoptstrip_tg_exit);
-MODULE_AUTHOR("Sven Schnelle <svens@bitebene.org>, Jan Engelhardt <jen=
gelh@computergmbh.de>");
+MODULE_AUTHOR("Sven Schnelle <svens@bitebene.org>, Jan Engelhardt <jen=
gelh@medozas.de>");
 MODULE_DESCRIPTION("Xtables: TCP option stripping");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_TCPOPTSTRIP");
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.=
c
index 26997ce..9e624af 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -5,7 +5,6 @@
  *   Nov 2002: Martin Bene <martin.bene@icomedias.com>:
  *		only ignore TIME_WAIT or gone connections
  *   (C) CC Computer Consultants GmbH, 2007
- *   Contact: <jengelh@computergmbh.de>
  *
  * based on ...
  *
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index d184515..97465a4 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -4,7 +4,7 @@
  *	Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com=
>
  *	by Henrik Nordstrom <hno@marasystems.com>
  *	Copyright =C2=A9 CC Computer Consultants GmbH, 2007 - 2008
- *	Jan Engelhardt <jengelh@computergmbh.de>
+ *	Jan Engelhardt <jengelh@medozas.de>
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.=
c
index 9e9c489..ba9601a 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -36,7 +36,7 @@
=20
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_AUTHOR("Jan Engelhardt <jengelh@computergmbh.de>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
 MODULE_DESCRIPTION("Xtables: per hash-bucket rate-limit match");
 MODULE_ALIAS("ipt_hashlimit");
 MODULE_ALIAS("ip6t_hashlimit");
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 7073dbb..1af74dd 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -34,7 +34,7 @@
 #include <linux/netfilter/xt_recent.h>
=20
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_AUTHOR("Jan Engelhardt <jengelh@computergmbh.de>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
 MODULE_DESCRIPTION("Xtables: \"recently-seen\" host matching for IPv4"=
);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_recent");
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 93acaa5..9a9c9a3 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -1,7 +1,6 @@
 /*
  *	xt_time
  *	Copyright =C2=A9 CC Computer Consultants GmbH, 2007
- *	Contact: <jengelh@computergmbh.de>
  *
  *	based on ipt_time by Fabrice MARIE <fabrice@netfilter.org>
  *	This is a module which is used for time matching
@@ -264,7 +263,7 @@ static void __exit time_mt_exit(void)
=20
 module_init(time_mt_init);
 module_exit(time_mt_exit);
-MODULE_AUTHOR("Jan Engelhardt <jengelh@computergmbh.de>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
 MODULE_DESCRIPTION("Xtables: time-based matching");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_time");
diff --git a/net/netfilter/xt_u32.c b/net/netfilter/xt_u32.c
index 24a5276..d7c05f0 100644
--- a/net/netfilter/xt_u32.c
+++ b/net/netfilter/xt_u32.c
@@ -3,7 +3,6 @@
  *
  *	Original author: Don Cohen <don@isis.cs3-inc.com>
  *	(C) CC Computer Consultants GmbH, 2007
- *	Contact: <jengelh@computergmbh.de>
  */
=20
 #include <linux/module.h>
@@ -117,7 +116,7 @@ static void __exit u32_mt_exit(void)
=20
 module_init(u32_mt_init);
 module_exit(u32_mt_exit);
-MODULE_AUTHOR("Jan Engelhardt <jengelh@computergmbh.de>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
 MODULE_DESCRIPTION("Xtables: arbitrary byte matching");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_u32");
--=20
1.7.0.4

