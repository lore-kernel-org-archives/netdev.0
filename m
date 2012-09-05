From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Wed, 05 Sep 2012 12:50:16 -0400 (EDT)
Message-ID: <20120905.125016.2259674613767082102.davem@davemloft.net>
References: <20120904.123740.1915830868205918256.davem@davemloft.net>
	<20120905044712.GA2284@netboy.at.omicron.at>
	<2037108.ZemStJh9zr@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab2IEQuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 12:50:20 -0400
In-Reply-To: <2037108.ZemStJh9zr@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Wed, 05 Sep 2012 08:24:25 +0200

> On Wednesday 05 September 2012 06:47:12 Richard Cochran wrote:
>> and so I think the problem that the test addresses is still present,
>> or am I missing something?
> 
> No,
> 
> you are right. Thank you.
> 
> Dave, for now, please don't apply this patch. In the long run, this crap
> in cdc-ncm needs to go. I am starting rewriting this driver right now.

I already applied it several days ago, someone send me a revert with a
verbose commit message explaining the situation.
