From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: replace tasklet with NAPI
Date: Wed, 14 Jan 2015 15:06:49 -0500 (EST)
Message-ID: <20150114.150649.475667638817956451.davem@davemloft.net>
References: <1394712342-15778-117-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-117-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 12 Jan 2015 12:06:23 +0800

> Replace tasklet with NAPI.
> 
> Add rx_queue to queue the remaining rx packets if the number of the
> rx packets is more than the request from poll().
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
