From: Dariusz Marcinkiewicz <reksio@newterm.pl>
Subject: [PATCH 2/2] MAINTAINERS: add entry for ec_bhf driver
Date: Fri, 15 Aug 2014 17:50:47 +0200
Message-ID: <20140815155046.GA16712@newterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.newterm.pl ([79.187.237.18]:51607 "EHLO apollo.newterm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbaHOQHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 12:07:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added entry for ec_bhf driver.

Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>
---
 MAINTAINERS |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7e2eb4c..b5416f8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1835,6 +1835,12 @@ S:	Orphan
 F:	Documentation/filesystems/befs.txt
 F:	fs/befs/
 
+BECKHOFF CX5020 ETHERCAT MASTER DRIVER
+M: Dariusz Marcinkiewicz <reksio@newterm.pl>
+L: netdev@vger.kernel.org
+S: Maintained
+F: drivers/net/ethernet/ec_bhf.c
+
 BFS FILE SYSTEM
 M:	"Tigran A. Aivazian" <tigran@aivazian.fsnet.co.uk>
 S:	Maintained
-- 
1.7.10.4
