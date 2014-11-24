From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] r8152: use ECM mode for future chips
Date: Sun, 23 Nov 2014 23:57:06 -0500 (EST)
Message-ID: <20141123.235706.1877570472649367521.davem@davemloft.net>
References: <1394712342-15778-101-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-101-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 24 Nov 2014 11:09:47 +0800

> For the future chips which the r8152 doesn't support yet, we could
> still use ECM mode for basic transmission.

Gross, please don't do this.
