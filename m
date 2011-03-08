From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [rds-devel] [PATCH] rds: prevent BUG_ON triggering on congestion map updates
Date: Tue, 08 Mar 2011 13:58:57 -0500
Message-ID: <1299610642-sup-5101@think>
References: <1299083302-5168-1-git-send-email-nhorman@tuxdriver.com> <20110307.122753.59686845.davem@davemloft.net> <1299530363-sup-8922@think> <20110308.105223.71117584.davem@davemloft.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: nhorman <nhorman@tuxdriver.com>, netdev <netdev@vger.kernel.org>,
	rds-devel <rds-devel@oss.oracle.com>,
	"venkat.x.venkatsubra" <venkat.x.venkatsubra@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25868 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080Ab1CHTAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 14:00:24 -0500
In-reply-to: <20110308.105223.71117584.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Excerpts from David Miller's message of 2011-03-08 13:52:23 -0500:
> From: Chris Mason <chris.mason@oracle.com>
> Date: Mon, 07 Mar 2011 15:41:04 -0500
> 
> > Excerpts from David Miller's message of 2011-03-07 15:27:53 -0500:
> >> From: Neil Horman <nhorman@tuxdriver.com>
> >> Date: Wed,  2 Mar 2011 11:28:22 -0500
> >> 
> >> > Recently had this bug halt reported to me:
> >> 
> >> Well, does anyone on the RDS team care about this bug fix at all?
> >> 
> >> Stuff like this should not sit for nearly a week without any reply
> >> whatsoever.
> >> 
> > 
> > The patch looks good to me, but I'm surprised we haven't seen it here.
> > Venkat please take a look (link to the patch below)  Has it only been seen on ppc?
> > 
> > http://permalink.gmane.org/gmane.linux.network/187933
> 
> Can I get an ACK or something, _please_?

Sorry, wasn't clear:

Acked-by: Chris Mason <chris.mason@oracle.com>

-chris
