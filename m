From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] r8152: add skb_cow_head
Date: Mon, 10 Mar 2014 22:25:20 -0400 (EDT)
Message-ID: <20140310.222520.814414646267623877.davem@davemloft.net>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	<1394504432-998-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394504432-998-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 11 Mar 2014 10:20:32 +0800

> Call skb_cow_head() before editing the tx packet header. The header
> would be reallocated if it is shared.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
