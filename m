From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ftgmac100/ftmac100: add missing interrupt.h
 include
Date: Wed, 18 Jan 2012 21:01:37 -0500 (EST)
Message-ID: <20120118.210137.1078675837531902060.davem@davemloft.net>
References: <4F1759A8.5080209@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ratbert@faraday-tech.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: thfabba@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F1759A8.5080209@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Faber <thfabba@gmx.de>
Date: Thu, 19 Jan 2012 00:45:44 +0100

> Fixes compilation failure of these modules due to missing
> irqreturn_t type for the ft(g)mac100_interrupt definition.
> 
> Signed-off-by: Thomas Faber <thfabba@gmx.de>

Applied, thanks.
