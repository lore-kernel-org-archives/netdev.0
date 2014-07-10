From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] r8152: support jumbo frame for RTL8153
Date: Thu, 10 Jul 2014 00:43:14 -0700 (PDT)
Message-ID: <20140710.004314.1668741288285519292.davem@davemloft.net>
References: <1394712342-15778-8-Taiwan-albertk@realtek.com>
	<1394712342-15778-9-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-9-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 10 Jul 2014 10:58:54 +0800

> The maximum jumbo frame size for RTL8153 is 9K bytes.
> Change the max rx packet size to 9K.
> Change the use of the shared fifo from 6K (default) to 12K for tx.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
