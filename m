From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/3] r8152: support new chips
Date: Thu, 15 Jun 2017 14:44:01 +0800
Message-ID: <1394712342-15778-278-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches are used to support new chips.

Hayes Wang (3):
  r8152: support new chip 8050
  r8152: support RTL8153B
  r8152: add byte_enable for ocp_read_word function

 drivers/net/usb/r8152.c | 687 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 671 insertions(+), 16 deletions(-)

-- 
2.7.4
