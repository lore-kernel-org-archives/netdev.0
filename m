From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/3] adjust the code of r8152
Date: Mon, 6 Jan 2014 17:08:40 +0800
Message-ID: <1388999323-9059-1-git-send-email-hayeswang@realtek.com>
References: <1388990366-8508-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388990366-8508-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace some tabs and modify the return value of rtl_ops_init().

v2: add the terminating newline for the message of patch #3.

Hayes Wang (3):
  r8152: replace some tabs with spaces
  r8152: move the actions of saving the information of the device
  r8152: replace the return value of rtl_ops_init

 drivers/net/usb/r8152.c | 43 +++++++++++++++++++++++--------------------
 1 file changed, 23 insertions(+), 20 deletions(-)

-- 
1.8.4.2
