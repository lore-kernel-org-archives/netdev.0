From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH v2 0/5] net: phy: dp83848: Add support for TI TLK10x Ethernet PHYs
Date: Sun, 7 Feb 2016 11:47:16 -0600
Message-ID: <1454867241-20928-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew F. Davis" <afd@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

This series is [0] split into its logical components.

Thanks,
Andrew

[0] http://www.spinics.net/lists/netdev/msg363106.html

Andrew F. Davis (5):
  net: phy: dp83848: Add macro for dp83848 compatible devices
  net: phy: dp83848: Add PHY ID for TI version of DP83848C
  net: phy: dp83848: Reorganize code for readability and safety
  net: phy: dp83848: Add support for TI TLK10x Ethernet PHYs
  net: phy: dp83848: Add comments for register definitions

 drivers/net/phy/dp83848.c | 88 ++++++++++++++++++++++++++++-------------------
 1 file changed, 52 insertions(+), 36 deletions(-)

-- 
2.7.0
