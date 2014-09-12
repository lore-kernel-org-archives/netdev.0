From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/2] r8169: fix rx vlan
Date: Fri, 12 Sep 2014 11:35:10 +0800
Message-ID: <1394712342-15778-38-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two issues for hw rx vlan. The patches are
used to fix them.

Hayes Wang (2):
  r8169: fix the default setting of rx vlan
  r8169: fix setting rx vlan

 drivers/net/ethernet/realtek/r8169.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

-- 
1.9.3
