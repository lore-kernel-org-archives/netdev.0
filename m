From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][MAINTAINERS]: The socketcan-core list is subscribers-only.
Date: Tue, 29 Apr 2008 10:56:04 +0400
Message-ID: <4816C684.6090200@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	urs.thuermann@volkswagen.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47048 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbYD2G65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 02:58:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I posted a copy_to_user fixes, the list daemon refused to accept
the Cc: <this-list>, because I was not a subscriber.

I found, that other lists with such a feature are marked respectively
in the MAINTAINERS file.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/MAINTAINERS b/MAINTAINERS
index 36aadf6..bd92fdd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1026,7 +1026,7 @@ P:	Urs Thuermann
 M:	urs.thuermann@volkswagen.de
 P:	Oliver Hartkopp
 M:	oliver.hartkopp@volkswagen.de
-L:	socketcan-core@lists.berlios.de
+L:	socketcan-core@lists.berlios.de (subscribers-only)
 W:	http://developer.berlios.de/projects/socketcan/
 S:	Maintained
 
