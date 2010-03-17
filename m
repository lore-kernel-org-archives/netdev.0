From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] route: Fix caught BUG_ON during
 rt_secret_rebuild_oneshot()
Date: Tue, 16 Mar 2010 20:54:40 -0400
Message-ID: <20100317005440.GA19957@hmsreliant.think-freely.org>
References: <20100316173543.GA13529@hmsreliant.think-freely.org>
 <1268762922.2932.3.camel@edumazet-laptop>
 <20100316181816.GC13529@hmsreliant.think-freely.org>
 <20100316.143028.54055122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, vgusev@openvz.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36207 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab0CQAyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 20:54:49 -0400
Content-Disposition: inline
In-Reply-To: <20100316.143028.54055122.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 16, 2010 at 02:30:28PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 16 Mar 2010 14:18:16 -0400
> 
> > Ok, I just figured it was time to pose the question, since we'd fixed several
> > bugs in this area over the last year.  Certainly doesn't hurt to keep the
> > rebuild timer around a bit longer.  I re-iterate my ack to Vitaliy's patch then.
> 
> Applied, thanks everyone.
> 
> I frankly would be OK with seeing the rebuild timer go away
> as early as 2.6.35
> 
I'll have something together for it around that time frame
Neil

