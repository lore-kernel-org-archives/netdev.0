From: David Miller <davem@davemloft.net>
Subject: Re: skbuff: Copy csum instead of csum_start/csum_offset
Date: Mon, 25 May 2009 00:41:05 -0700 (PDT)
Message-ID: <20090525.004105.187030775.davem@davemloft.net>
References: <20090523082002.GA14135@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49538
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759714AbZEYHlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 03:41:06 -0400
In-Reply-To: <20090523082002.GA14135@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 23 May 2009 18:20:02 +1000

> skbuff: Copy csum instead of csum_start/csum_offset
> 
> It's easier to copy the u32 csum instead of its two u16
> constituents.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6
