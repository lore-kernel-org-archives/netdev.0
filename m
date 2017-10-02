From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v3 17/19] MAINTAINERS: Add thunderbolt.h to the Thunderbolt driver entry
Date: Mon,  2 Oct 2017 13:38:44 +0300
Message-ID: <20171002103846.64602-18-mika.westerberg@linux.intel.com>
References: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new API header (include/linux/thunderbolt.h) is maintained by the
Thunderbolt driver maintainers.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 65b0c88d5ee0..34661b5ac9ad 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -13284,6 +13284,7 @@ M:	Mika Westerberg <mika.westerberg@linux.intel.com>
 M:	Yehezkel Bernat <yehezkel.bernat@intel.com>
 S:	Maintained
 F:	drivers/thunderbolt/
+F:	include/linux/thunderbolt.h
 
 THUNDERX GPIO DRIVER
 M:	David Daney <david.daney@cavium.com>
-- 
2.14.2
