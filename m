From: David Miller <davem@davemloft.net>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 14:47:09 -0700 (PDT)
Message-ID: <20071002.144709.123999983.davem@davemloft.net>
References: <20071002164858.GH17418@bitmover.com>
	<20071002.141656.42880006.davem@davemloft.net>
	<20071002212608.GG29944@bitmover.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, herbert@gondor.apana.org.au,
	wscott@bitmover.com, netdev@vger.kernel.org
To: lm@bitmover.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752509AbXJBVrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:47:10 -0400
In-Reply-To: <20071002212608.GG29944@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lm@bitmover.com (Larry McVoy)
Date: Tue, 2 Oct 2007 14:26:08 -0700

> And note that sky2 doesn't have this problem.  Does the broadcom do TSO?
> And sky2 not?  I noticed a much higher CPU load for sky2.

Yes the broadcoms (the revisions I have) do TSO and it is enabled
on both sides.

Which makes the mis-matched performance even stranger :)
