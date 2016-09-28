From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v8 8/8] thunderbolt: Adding maintainer entry
Date: Wed, 28 Sep 2016 17:44:30 +0300
Message-ID: <1475073870-2126-9-git-send-email-amir.jer.levy@intel.com>
References: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Amir Levy as maintainer for Thunderbolt(TM) ICM driver

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 MAINTAINERS | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 01bff8e..a4a4614 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10358,7 +10358,13 @@ F:	include/uapi/linux/stm.h
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
