From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipv4: do not ignore route errors
Date: Sun, 27 Mar 2011 09:35:37 +0900
Message-ID: <20110327003536.GD31554@verge.net.au>
References: <201103252345.p2PNjP1n025209@ja.ssi.bg>
 <20110325.203338.193726112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34123 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab1C0Afn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 20:35:43 -0400
Content-Disposition: inline
In-Reply-To: <20110325.203338.193726112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2011 at 08:33:38PM -0700, David Miller wrote:
> From: Julian Anastasov <ja@ssi.bg>
> Date: Sat, 26 Mar 2011 01:45:25 +0200
> 
> > 	The "ipv4: Inline fib_semantic_match into check_leaf"
> > change forgets to return the route errors. check_leaf should
> > return the same results as fib_table_lookup.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Your mailer corrupted this patch, so I applied it by hand.

I have noticed that Julian's patches usually arrive
with two leading spaces where there should be one but
are otherwise intact.  And that its not a new thing,
I can remember seeing this 6 months ago, and I don't think
it was a new thing then either.

Just an observation.

