From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 05 Dec 2007 02:08:08 -0800 (PST)
Message-ID: <20071205.020808.128056400.davem@davemloft.net>
References: <20071205095159.GA16860@gondor.apana.org.au>
	<20071205.020248.50886654.davem@davemloft.net>
	<20071205100452.GA18026@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751369AbXLEKIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 05:08:09 -0500
In-Reply-To: <20071205100452.GA18026@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 5 Dec 2007 21:04:52 +1100

> On Wed, Dec 05, 2007 at 02:02:48AM -0800, David Miller wrote:
> >
> > Herbert, I applied the buggered patch and pushed it out
> > already, can you send me this fix relative?
> > 
> > I'll combine them on my next rebase, thanks.
> 
> Sure, here it is.

Applied, thanks a lot.
