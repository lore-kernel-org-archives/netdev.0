From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoe: Use workqueue to die properly when a PADT is
 received
Date: Sat, 21 Feb 2015 21:58:22 -0500 (EST)
Message-ID: <20150221.215822.1404722842047278123.davem@davemloft.net>
References: <2498181.kKNYHvd3hx@f19simon>
	<20150220204923.13275ydcca5wwwcj@berry.schulz.ip-v6.eu>
	<2335170.7Jqfc2NRFK@hummingbird.farnz.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: develop@kristov.de, netdev@vger.kernel.org, dcbw@redhat.com,
	mostrows@gmail.com, linux-ppp@vger.kernel.org
To: simon@farnz.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbbBVC6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 21:58:25 -0500
In-Reply-To: <2335170.7Jqfc2NRFK@hummingbird.farnz.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Farnsworth <simon@farnz.org.uk>
Date: Fri, 20 Feb 2015 21:04:53 +0000

> However, I think I should probably do a v2 patch with a clear commit message, 
> so that if someone does bisect down to this commit as a cause of the "error" 
> they're seeing, they'll understand why it's not a problem.

Ok then, I'll wait for that v2.
