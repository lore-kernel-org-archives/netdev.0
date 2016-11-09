From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v9 8/8] thunderbolt: Adding maintainer entry
Date: Wed,  9 Nov 2016 16:20:08 +0200
Message-ID: <1478701208-4585-9-git-send-email-amir.jer.levy@intel.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:43552 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932390AbcKIMVP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 07:21:15 -0500
In-Reply-To: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Amir Levy as maintainer for Thunderbolt(TM) ICM driver

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 MAINTAINERS | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 411e3b8..87763c44 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10652,7 +10652,13 @@ F:	include/uapi/linux/stm.h
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
+F:	Documentation/thunderbolt/networking.txt
 
 TI BQ27XXX POWER SUPPLY DRIVER
 R:	Andrew F. Davis <afd@ti.com>
-- 
2.7.4
