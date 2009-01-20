From: David Miller <davem@davemloft.net>
Subject: Re: net: Add debug info to track down GSO checksum bug
Date: Mon, 19 Jan 2009 16:26:52 -0800 (PST)
Message-ID: <20090119.162652.02404892.davem@davemloft.net>
References: <20090116072251.GA13327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754546AbZATA0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:26:50 -0500
In-Reply-To: <20090116072251.GA13327@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 16 Jan 2009 18:22:51 +1100

> net: Add debug info to track down GSO checksum bug
> 
> I'm trying to track down why people're hitting the checksum warning
> in skb_gso_segment.  As the problem seems to be hitting lots of
> people and I can't reproduce it or locate the bug, here is a patch
> to print out more details which hopefully should help us to track
> this down.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
