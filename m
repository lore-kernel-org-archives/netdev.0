From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: missing headers (sparse)
Date: Thu, 12 Apr 2012 16:39:17 +0300
Message-ID: <1334237958-22855-2-git-send-email-remi@remlab.net>
References: <1334237958-22855-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oyp.chewa.net ([91.121.6.101]:50539 "EHLO oyp.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934193Ab2DLNqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 09:46:55 -0400
In-Reply-To: <1334237958-22855-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/sysctl.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index cea1c7d..740bf20 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -27,6 +27,10 @@
 #include <linux/errno.h>
 #include <linux/init.h>
=20
+#include <net/sock.h>
+#include <linux/phonet.h>
+#include <net/phonet/phonet.h>
+
 #define DYNAMIC_PORT_MIN	0x40
 #define DYNAMIC_PORT_MAX	0x7f
=20
--=20
1.7.5.4
