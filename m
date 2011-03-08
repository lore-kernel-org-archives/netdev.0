From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [rds-devel] [PATCH] rds: prevent BUG_ON triggering on congestion
 map updates
Date: Tue, 8 Mar 2011 14:36:42 -0500
Message-ID: <20110308193642.GB19669@hmsreliant.think-freely.org>
References: <1299530363-sup-8922@think>
 <20110308.105223.71117584.davem@davemloft.net>
 <1299610642-sup-5101@think>
 <20110308.112258.183048712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chris.mason@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, venkat.x.venkatsubra@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49855 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab1CHTgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 14:36:47 -0500
Content-Disposition: inline
In-Reply-To: <20110308.112258.183048712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2011 at 11:22:58AM -0800, David Miller wrote:
> From: Chris Mason <chris.mason@oracle.com>
> Date: Tue, 08 Mar 2011 13:58:57 -0500
> 
> > Excerpts from David Miller's message of 2011-03-08 13:52:23 -0500:
> >> From: Chris Mason <chris.mason@oracle.com>
> >> Date: Mon, 07 Mar 2011 15:41:04 -0500
> >> 
> >> > Excerpts from David Miller's message of 2011-03-07 15:27:53 -0500:
> >> >> From: Neil Horman <nhorman@tuxdriver.com>
> >> >> Date: Wed,  2 Mar 2011 11:28:22 -0500
> >> >> 
> >> >> > Recently had this bug halt reported to me:
> >> >> 
> >> >> Well, does anyone on the RDS team care about this bug fix at all?
> >> >> 
> >> >> Stuff like this should not sit for nearly a week without any reply
> >> >> whatsoever.
> >> >> 
> >> > 
> >> > The patch looks good to me, but I'm surprised we haven't seen it here.
> >> > Venkat please take a look (link to the patch below)  Has it only been seen on ppc?
> >> > 
> >> > http://permalink.gmane.org/gmane.linux.network/187933
> >> 
> >> Can I get an ACK or something, _please_?
> > 
> > Sorry, wasn't clear:
> > 
> > Acked-by: Chris Mason <chris.mason@oracle.com>
> 
> Applied, thanks everyone.
Thanks, Chris, Dave.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
