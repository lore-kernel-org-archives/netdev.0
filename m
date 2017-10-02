From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v3 19/19] MAINTAINERS: Add entry for Thunderbolt network driver
Date: Mon,  2 Oct 2017 13:38:46 +0300
Message-ID: <20171002103846.64602-20-mika.westerberg@linux.intel.com>
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

I will be maintaining the Thunderbolt network driver along with Michael
and Yehezkel.

Signed-off-by: Michael Jamet <michael.jamet@intel.com>
Signed-off-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 34661b5ac9ad..745527d5e326 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -13286,6 +13286,14 @@ S:	Maintained
 F:	drivers/thunderbolt/
 F:	include/linux/thunderbolt.h
 
+THUNDERBOLT NETWORK DRIVER
+M:	Michael Jamet <michael.jamet@intel.com>
+M:	Mika Westerberg <mika.westerberg@linux.intel.com>
+M:	Yehezkel Bernat <yehezkel.bernat@intel.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/thunderbolt.c
+
 THUNDERX GPIO DRIVER
 M:	David Daney <david.daney@cavium.com>
 S:	Maintained
-- 
2.14.2
