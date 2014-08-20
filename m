From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/4] r8152: firmware support
Date: Wed, 20 Aug 2014 16:58:35 +0800
Message-ID: <1394712342-15778-16-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Parsing, checking, and writing the firmware.

Hayes Wang (4):
  r8152: check code with checkpatch.pl
  r8152: replace strncpy with strlcpy
  r8152: remove clear_bp function
  r8152: support firmware files

 drivers/net/usb/r8152.c | 961 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 903 insertions(+), 58 deletions(-)

-- 
1.9.3
