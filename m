From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: don't execute runtime suspend if the tx is
 not empty
Date: Tue, 24 Jan 2017 13:39:25 -0500 (EST)
Message-ID: <20170124.133925.2008738155868268449.davem@davemloft.net>
References: <1394712342-15778-235-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-235-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 23 Jan 2017 14:18:43 +0800

> Runtime suspend shouldn't be executed if the tx queue is not empty,
> because the device is not idle.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied and queued up for -stable, thanks.
