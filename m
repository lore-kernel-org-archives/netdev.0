From: xeb@mail.ru
Subject: =?koi8-r?Q?[PATCH_3/3]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Wed, 04 Aug 2010 14:48:33 +0400
Message-ID: <E1OgbWT-0004Ij-00.xeb-mail-ru@f134.mail.ru>
Reply-To: xeb@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from f134.mail.ru ([217.69.128.89]:36955 "EHLO f134.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932518Ab0HDKsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 06:48:35 -0400
Received: from mail by f134.mail.ru with local
	id 1OgbWT-0004Ij-00
	for netdev@vger.kernel.org; Wed, 04 Aug 2010 14:48:33 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is patch 3/3 which contains MAINTAINERS file modification.

---
 MAINTAINERS |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 02f75fc..313d829 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6450,6 +6450,20 @@ M:	"Maciej W. Rozycki" <macro@linux-mips.org>
 S:	Maintained
 F:	drivers/serial/zs.*
 
+GRE DEMULTIPLEXER DRIVER
+M:	Dmitry Kozlov <xeb@mail.ru>
+L:	linux-net@vger.kernel.org
+S:	Maintained
+F:	net/ipv4/gre.c
+F:	include/net/gre.h
+
+PPTP DRIVER
+M:	Dmitry Kozlov <xeb@mail.ru>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/pptp.c
+W:	http://accel-pptp.sourceforge.net/
+
 THE REST
 M:	Linus Torvalds <torvalds@linux-foundation.org>
 L:	linux-kernel@vger.kernel.org
