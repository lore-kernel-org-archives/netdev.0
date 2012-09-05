From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Wed, 05 Sep 2012 08:24:25 +0200
Message-ID: <2037108.ZemStJh9zr@linux-lqwf.site>
References: <1346768514-19823-1-git-send-email-oliver@neukum.org> <20120904.123740.1915830868205918256.davem@davemloft.net> <20120905044712.GA2284@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45516 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826Ab2IEHQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 03:16:52 -0400
In-Reply-To: <20120905044712.GA2284@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 September 2012 06:47:12 Richard Cochran wrote:
> and so I think the problem that the test addresses is still present,
> or am I missing something?

No,

you are right. Thank you.

Dave, for now, please don't apply this patch. In the long run, this crap
in cdc-ncm needs to go. I am starting rewriting this driver right now.

	Regards
		Oliver
