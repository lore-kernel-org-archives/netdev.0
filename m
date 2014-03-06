From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 0/3] r8152: cleanups
Date: Thu, 6 Mar 2014 15:07:15 +0800
Message-ID: <1394089638-1580-1-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393934464-23675-1-git-send-email-hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Deal with some empty lines and spaces, replace some tp->netdev with netdev,
and remove the unnecessary function.

Hayes Wang (3):
  r8152: deal with the empty line and space
  r8152: replace tp->netdev with netdev
  r8152: remove rtl8152_get_stats

 drivers/net/usb/r8152.c | 36 ++++++++++++++++--------------------
 1 file changed, 16 insertions(+), 20 deletions(-)

-- 
1.8.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
