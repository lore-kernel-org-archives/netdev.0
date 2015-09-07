From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/2] fix the autoresume may fail
Date: Mon, 7 Sep 2015 11:57:42 +0800
Message-ID: <1394712342-15778-166-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the autosuspend issues which occur about linking change.

Hayes Wang (2):
  r8152: split DRIVER_VERSION
  r8152: fix the runtime suspend issues

 drivers/net/usb/r8152.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 63 insertions(+), 3 deletions(-)

-- 
2.4.3
