From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/2] r8152: rx patches
Date: Fri, 11 Nov 2016 15:15:39 +0800
Message-ID: <1394712342-15778-226-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, <mlord@pobox.com>,
        Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let the rx sw checksum available and add some checks for rx desc.

Hayes Wang (2):
  r8152: fix the sw rx checksum is unavailable
  r8152: rx descriptor check

 drivers/net/usb/r8152.c | 46 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 45 insertions(+), 1 deletion(-)

-- 
2.7.4
