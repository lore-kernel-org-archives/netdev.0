From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] caching bundles, iteration 3
Date: Thu, 01 Apr 2010 20:00:42 -0700 (PDT)
Message-ID: <20100401.200042.206653087.davem@davemloft.net>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45521
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753191Ab0DBDAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 23:00:40 -0400
In-Reply-To: <1270126340-30181-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Thu,  1 Apr 2010 15:52:16 +0300

> Applies on top of the previous patches I sent.
> 
> Changes to previous iteration:
>  - "flow: delayed deletion of flow cache entries" refactored to go
>    after the other patches per Herbert's request
>  - fixed hlist searching in the above mentioned patch
>  - uses now ERR_CAST and other similar functions for better readability
>  - added basic gc for per-socket bundles
>  - some other minor clean ups
> 
> I'm now running this on a test box, with my specific setup, and it
> seems to be working pretty well. However, this changes quite a bit
> of things, so detailed review is needed.

I'm kind of burnt out on patch review for today, so I hope Herbert
can take a look at this when he wakes up.

Otherwise I'll study it in detail tomorrow.

Thanks Timo!
