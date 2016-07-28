From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v5 8/8] thunderbolt: Adding maintainer entry
Date: Thu, 28 Jul 2016 11:15:21 +0300
Message-ID: <1469693721-5641-9-git-send-email-amir.jer.levy@intel.com>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	thunderbolt-linux@intel.com, mika.westerberg@intel.com,
	tomas.winkler@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, corbet@lwn.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Amir Levy as maintainer for Thunderbolt(TM) ICM driver

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 MAINTAINERS | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 771c31c..5f24eb2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10141,7 +10141,13 @@ F:	include/uapi/linux/stm.h
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

