From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/16] net/ax25: Use available error codes
Date: Wed, 18 Aug 2010 14:28:30 -0700 (PDT)
Message-ID: <20100818.142830.246516044.davem@davemloft.net>
References: <Pine.LNX.4.64.1008161828030.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754439Ab0HRV2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 17:28:11 -0400
In-Reply-To: <Pine.LNX.4.64.1008161828030.19313@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Mon, 16 Aug 2010 18:28:19 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> Error codes are stored in err, but the return value is always 0.  Return
> err instead.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
