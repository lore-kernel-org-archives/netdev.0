From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] r8152: rtl_ops_init modify
Date: Thu, 06 Nov 2014 15:15:26 -0500 (EST)
Message-ID: <20141106.151526.1810370548228119689.davem@davemloft.net>
References: <1394712342-15778-84-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-84-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 6 Nov 2014 12:47:37 +0800

> Initialize the ops through tp->version. This could skip checking
> each VID/PID.

Series applied, thank you.
