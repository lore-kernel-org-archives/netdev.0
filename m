From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if
 subtree does not match
Date: Tue, 13 Aug 2013 01:15:50 -0700 (PDT)
Message-ID: <20130813.011550.791636011692333018.davem@davemloft.net>
References: <2A0809D4-EBF1-4646-9564-2B7F54956B41@inf-net.nl>
	<20130810120348.GP14001@order.stressinduktion.org>
	<190D21D2-F86E-46D2-93E8-3050F57FE622@inf-net.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: teco@inf-net.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab3HMIPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 04:15:51 -0400
In-Reply-To: <190D21D2-F86E-46D2-93E8-3050F57FE622@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Teco Boot <teco@inf-net.nl>
Date: Tue, 13 Aug 2013 10:02:08 +0200

> It is an important element in my work for v6 multi-homed networks
> (IETF Homenet WG).

You are one person.  -stable inclusion is decided based how important the
fix is to everyone in both good (fixes a bug) and bad (might cause a
regression) terms.

So "this is important for my work" is never a good reason for a patch
to be included into -stable.

To convince us, you're going to have to present an argument that
exists outside the very limited scope of your own self-interests.
And "other people might/will use my important work in the future"
is not sufficient either.

Thanks.
