From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 4 Jul 2008 22:10:15 +0100
Message-ID: <20080704221015.54bdc8d2@lxorguk.ukuu.org.uk>
References: <1215178035.10393.763.camel@pmac.infradead.org>
	<20080704.133721.98729739.davem@davemloft.net>
	<20080704134208.6c712031@infradead.org>
	<20080704.135150.250580915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, dwmw2@infradead.org, jeff@garzik.org,
	andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:38379 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751492AbYGDV2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 17:28:50 -0400
In-Reply-To: <20080704.135150.250580915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It seems your employer is telling you to work on this in order to sort
> out some perceived legal issue.  And that's the only reason you're
> investing any effort into this.

To point out the blindingly obvious

1. - David has had *two* different employers while working on this project

2. - I think you could reasonably assume that if your employers legal
team had reached a specific conclusion that there was a compliance issue
they would have directed you to do something about it as well, not
operated a mysterious conspiracy (in conjunction one assumes with David's
current employer) to change it.

And it's worth remembering that the 'lunatic fringe' you seem to be
trying to associate David with don't care about the firmware changes
because their view is that you shouldn't even have drivers for such
hardware as it cannot be used in a free way (just as they argue not to
write java without free interpreters). [1]

Alan
[1] No I don't know where they get their free x86 engine from either ;)
