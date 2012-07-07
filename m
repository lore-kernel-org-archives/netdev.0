From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix non-ANSI function declaration warning
Date: Sat, 07 Jul 2012 16:12:35 -0700 (PDT)
Message-ID: <20120707.161235.1181930264623743070.davem@davemloft.net>
References: <1341686871-21822-1-git-send-email-emilgoode@gmail.com>
	<1341691049.25597.169.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emilgoode@gmail.com, edumazet@google.com, mirq-linux@rere.qmqm.pl,
	jpirko@redhat.com, therbert@google.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab2GGXMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 19:12:43 -0400
In-Reply-To: <1341691049.25597.169.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 7 Jul 2012 20:57:29 +0100

> On Sat, 2012-07-07 at 20:47 +0200, Emil Goode wrote:
>> Sparse is warning about non-ANSI function declaration.
>> Add void to the parameterless function.
>> 
>> net/core/dev.c:1804:38: warning:
>> 	non-ANSI function declaration of function
>> 	'netif_get_num_default_rss_queues'
> 
> I also posted a patch for this (and another instance I found).

But you were asked to fix up the comment formatting in on of those
patches so you need to fix that up and resubmit the entire set.
