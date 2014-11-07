From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/2] r8152: adjust rx functions
Date: Fri, 7 Nov 2014 17:55:09 +0800
Message-ID: <1394712342-15778-88-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust some flows and codes which are relative to r8152_submit_rx()
and rtl_start_rx().

Hayes Wang (2):
  r8152: adjust r8152_submit_rx
  r8152: adjust rtl_start_rx

 drivers/net/usb/r8152.c | 51 +++++++++++++++++++++++++++----------------------
 1 file changed, 28 insertions(+), 23 deletions(-)

-- 
1.9.3
