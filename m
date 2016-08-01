From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v6 8/8] thunderbolt: Adding maintainer entry
Date: Mon,  1 Aug 2016 15:23:53 +0300
Message-ID: <1470054233-4309-9-git-send-email-amir.jer.levy@intel.com>
References: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	thunderbolt-linux@intel.com, mika.westerberg@intel.com,
	tomas.winkler@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, corbet@lwn.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20355 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753660AbcHAMZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 08:25:36 -0400
In-Reply-To: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Amir Levy as maintainer for Thunderbolt(TM) ICM driver

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 MAINTAINERS | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 72f7703..2b6d635 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10193,7 +10193,13 @@ F:	include/uapi/linux/stm.h
 THUNDERBOLT DRIVER
 M:	Andreas Noever <andreas.noever@gmail.com>
 S:	Maintained
-F:	drivers/thunderbolt/
+F:	drivers/thunderbolt/*
+
+THUNDERBOLT ICM DRIVER
+M:	Amir Levy <amir.jer.levy@intel.com>
+S:	Maintained
+F:	drivers/thunderbolt/icm/
+F:	Documentation/thunderbolt-networking.txt
 
 TI BQ27XXX POWER SUPPLY DRIVER
 R:	Andrew F. Davis <afd@ti.com>
-- 
2.7.4
