From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/2] r8152: support nway_reset
Date: Tue, 28 Oct 2014 14:05:50 +0800
Message-ID: <1394712342-15778-66-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the CHECK from checkpatch.pl and support nway_reset.

Hayes Wang (2):
  r8152: rename tx_underun
  r8152: support nway_reset of ethtool

 drivers/net/usb/r8152.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

-- 
1.9.3
