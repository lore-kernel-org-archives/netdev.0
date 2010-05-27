From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/11] drivers/net: Eliminate a NULL pointer dereference
Date: Thu, 27 May 2010 16:30:16 -0700 (PDT)
Message-ID: <20100527.163016.48525549.davem@davemloft.net>
References: <Pine.LNX.4.64.1005271433180.5422@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1005271433180.5422@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Thu, 27 May 2010 14:33:32 +0200 (CEST)

> At the point of the print, dev is NULL.
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks.
