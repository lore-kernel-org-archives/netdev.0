From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: fix non-ANSI function declaration warning
Date: Sun, 8 Jul 2012 01:16:03 +0100
Message-ID: <1341706563.25597.170.camel@deadeye.wl.decadent.org.uk>
References: <1341686871-21822-1-git-send-email-emilgoode@gmail.com>
	 <1341691049.25597.169.camel@deadeye.wl.decadent.org.uk>
	 <20120707.161235.1181930264623743070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <emilgoode@gmail.com>, <edumazet@google.com>,
	<mirq-linux@rere.qmqm.pl>, <jpirko@redhat.com>,
	<therbert@google.com>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46589 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750975Ab2GHAQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 20:16:09 -0400
In-Reply-To: <20120707.161235.1181930264623743070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-07 at 16:12 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Sat, 7 Jul 2012 20:57:29 +0100
> 
> > On Sat, 2012-07-07 at 20:47 +0200, Emil Goode wrote:
> >> Sparse is warning about non-ANSI function declaration.
> >> Add void to the parameterless function.
> >> 
> >> net/core/dev.c:1804:38: warning:
> >> 	non-ANSI function declaration of function
> >> 	'netif_get_num_default_rss_queues'
> > 
> > I also posted a patch for this (and another instance I found).
> 
> But you were asked to fix up the comment formatting in on of those
> patches so you need to fix that up and resubmit the entire set.

You have got to be kidding.  I fixed one thing, so I have to fix
another?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
