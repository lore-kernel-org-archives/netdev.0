From: David Miller <davem@davemloft.net>
Subject: Re: [0/4] gro: Optimise GRO receive functions
Date: Sun, 08 Feb 2009 22:04:34 -0800 (PST)
Message-ID: <20090208.220434.120106670.davem@davemloft.net>
References: <20090209035930.GA2988@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55583
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753015AbZBIGEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 01:04:40 -0500
In-Reply-To: <20090209035930.GA2988@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 9 Feb 2009 14:59:30 +1100

> Hi Dave:
> 
> This is a split up version of a patch that Divy tested earlier.
> I was going to do this earlier but I wanted to track down the
> igb/ixgbe regressions first.
> 
> After this I'm going to look at moving the skb construction calls
> into cxgb3 itself in order to avoid copying the meta data twice.

All applied, thanks Herbert.
