From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 09:25:34 -0700
Message-ID: <20071002162534.GG17418@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: lm@bitmover.com, Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43382 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751669AbXJBQZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 12:25:35 -0400
Content-Disposition: inline
In-Reply-To: <20071002154137.GD17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If the server side is the source of the data, i.e, it's transfer is a 
> write loop, then I get the bad behaviour.  
> ...
> So is this a bug or intentional?

For whatever it is worth, I believed that we used to get better performance
from the same hardware.  My guess is that it changed somewhere between
2.6.15-1-k7 and 2.6.18-5-k7.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
