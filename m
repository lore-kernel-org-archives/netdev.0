From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] drivers/net/phy: introduce missing kfree
Date: Fri, 11 Sep 2009 12:13:42 -0700 (PDT)
Message-ID: <20090911.121342.40455624.davem@davemloft.net>
References: <Pine.LNX.4.64.0909111821520.10552@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756070AbZIKTN3@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0909111821520.10552@pc-004.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Fri, 11 Sep 2009 18:22:09 +0200 (CEST)

> Error handling code following a kzalloc should free the allocated data.
> 
> The semantic match that finds the problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
