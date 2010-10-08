From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 1/4] Phonet: add to MAINTAINERS and add myself
Date: Fri,  8 Oct 2010 17:02:00 +0300
Message-ID: <1286546523-3340-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47818 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758128Ab0JHOCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 10:02:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 MAINTAINERS |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9ddb5ac..1fd58ef 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4541,6 +4541,14 @@ L:	linux-abi-devel@lists.sourceforge.net
 S:	Maintained
 F:	include/linux/personality.h
=20
+PHONET PROTOCOL
+M:	Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+S:	Supported
+F:	Documentation/networking/phonet.txt
+F:	include/linux/phonet.h
+F:	include/net/phonet/
+F:	net/phonet/
+
 PHRAM MTD DRIVER
 M:	Joern Engel <joern@lazybastard.org>
 L:	linux-mtd@lists.infradead.org
--=20
1.7.0.4

