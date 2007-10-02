From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 11:35:39 -0700
Message-ID: <20071002183538.GA29944@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com> <4702766E.80202@candelatech.com> <20071002171154.GM17418@bitmover.com> <47027D80.4070506@candelatech.com> <20071002172155.GP17418@bitmover.com> <20071002105423.5d61a727@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry McVoy <lm@bitmover.com>,
	Ben Greear <greearb@candelatech.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43659 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752173AbXJBSfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 14:35:41 -0400
Content-Disposition: inline
In-Reply-To: <20071002105423.5d61a727@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Make sure you don't have slab debugging turned on. It kills performance.

It's a stock debian kernel, so unless they turn it on it's off.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
