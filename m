From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivres/net: Change constant name
Date: Wed, 12 Aug 2009 21:19:14 -0700 (PDT)
Message-ID: <20090812.211914.14779651.davem@davemloft.net>
References: <Pine.LNX.4.64.0908080953090.25176@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752024AbZHMETH@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0908080953090.25176@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 8 Aug 2009 09:53:41 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> In this series of tests the constants have the form XRXMAC_STATUS, except
> in this one case.  The values of XRXMAC_STAT_MSK_RXOCTET_CNT_EXP and
> XRXMAC_STATUS_RXOCTET_CNT_EXP are furthermore the same.
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
