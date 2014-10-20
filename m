From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable v3.2 v3.4] ipv4: disable bh while doing route gc
Date: Mon, 20 Oct 2014 00:23:08 -0400 (EDT)
Message-ID: <20141020.002308.1276148768580405795.davem@davemloft.net>
References: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
	<20141013.135127.1915115817707962111.davem@davemloft.net>
	<1413774581.31953.12.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, stable@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbaJTEXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 00:23:13 -0400
In-Reply-To: <1413774581.31953.12.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 20 Oct 2014 04:09:41 +0100

> I've appplied this and the previous two patches mentioned ('ipv4: move
> route garbage collector to work queue' and 'ipv4: avoid parallel route
> cache gc executions').  But I didn't get the other two from you.  The
> last batch of networking fixes I received and applied was dated
> 2014-08-07, and the next one I've seen is dated 2014-10-11 and has
> nothing for 3.2 or 3.4.  Did I miss one between these?

I'm at the point where I'm personally not going to go back more than
four releases, anything more than that is rediculous.

And this time that was 3.17, 3.16, 3.14, and 3.10
