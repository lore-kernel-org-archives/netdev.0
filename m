From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/2] parameter modification
Date: Thu, 13 Mar 2014 11:34:06 +0800
Message-ID: <1394681648-7321-1-git-send-email-albertk@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add opportunity to change the default setting and reduce the tx/rx
buffers.

v2: modify the patch #1 to let the value readable.

Hayes Wang (2):
  r8152: add RTL8152_EARLY_AGG_TIMEOUT_SUPER
  r8152: reduce the numbers of the bulks

 drivers/net/usb/Kconfig | 11 +++++++++++
 drivers/net/usb/r8152.c | 10 ++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

-- 
1.8.4.2
