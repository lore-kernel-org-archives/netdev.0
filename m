From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: clear LINK_OFF_WAKE_EN after autoresume
Date: Fri, 01 Jul 2016 05:57:37 -0400 (EDT)
Message-ID: <20160701.055737.515449390875714786.davem@davemloft.net>
References: <1394712342-15778-206-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-206-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 30 Jun 2016 15:33:35 +0800

> LINK_OFF_WAKE_EN should be cleared after autoresume, otherwise after
> system suspend, the system would wake up when linking off occurs.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
