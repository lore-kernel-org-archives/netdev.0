From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?[PATCH_v2_3/3]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Thu, 05 Aug 2010 13:39:24 +0400
Message-ID: <E1Ogwv6-00032e-00.xeb-mail-ru@f278.mail.ru>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from f278.mail.ru ([217.69.128.247]:34252 "EHLO f278.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758997Ab0HEJjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 05:39:25 -0400
Received: from mail by f278.mail.ru with local
	id 1Ogwv6-00032e-00
	for netdev@vger.kernel.org; Thu, 05 Aug 2010 13:39:24 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is patch 3/3 which contains MAINTAINERS file modification.

---
 MAINTAINERS |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 02f75fc..191d7c4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6450,6 +6450,20 @@ M:	"Maciej W. Rozycki" <macro@linux-mips.org>
 S:	Maintained
 F:	drivers/serial/zs.*
 
+GRE DEMULTIPLEXER DRIVER
+M:	Dmitry Kozlov <D.Kozlov@protek-vrn.ru>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	net/ipv4/gre.c
+F:	include/net/gre.h
+
+PPTP DRIVER
+M:	Dmitry Kozlov <D.Kozlov@protek-vrn.ru>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/pptp.c
+W:	http://sourceforge.net/projects/accel-pptp
+
 THE REST
 M:	Linus Torvalds <torvalds@linux-foundation.org>
 L:	linux-kernel@vger.kernel.org
