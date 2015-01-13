From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable: Add MAINTAINERS entry
Date: Tue, 13 Jan 2015 01:01:24 +0100
Message-ID: <cf5552c116d0fe998a3b660d5850b7c2efd814b5.1421107185.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53072 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbAMAB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 19:01:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 3309895..0c2983a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8014,6 +8014,13 @@ S:	Maintained
 F:	Documentation/rfkill.txt
 F:	net/rfkill/
 
+RHASHTABLE
+M:	Thomas Graf <tgraf@suug.ch>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	lib/rhashtable.c
+F:	include/linux/rhashtable.h
+
 RICOH SMARTMEDIA/XD DRIVER
 M:	Maxim Levitsky <maximlevitsky@gmail.com>
 S:	Maintained
-- 
1.9.3
