From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/20] drivers/net: Use kcalloc or kzalloc
Date: Mon, 17 May 2010 22:55:55 -0700 (PDT)
Message-ID: <20100517.225555.267953461.davem@davemloft.net>
References: <Pine.LNX.4.64.1005132205420.6282@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56012
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755736Ab0ERFzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:55:47 -0400
In-Reply-To: <Pine.LNX.4.64.1005132205420.6282@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Thu, 13 May 2010 22:06:01 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> Use kcalloc or kzalloc rather than the combination of kmalloc and memset.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
