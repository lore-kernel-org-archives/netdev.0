From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 13:27:16 -0700 (PDT)
Message-ID: <20080915.132716.267218808.davem@davemloft.net>
References: <20080913203548.GA2989@havoc.gtf.org>
	<20080915.120917.36004302.davem@davemloft.net>
	<20080915201749.GB3994@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48686
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754453AbYIOU1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 16:27:22 -0400
In-Reply-To: <20080915201749.GB3994@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 15 Sep 2008 16:17:50 -0400

> On Mon, Sep 15, 2008 at 12:09:17PM -0700, David Miller wrote:
> > From: Jeff Garzik <jeff@garzik.org>
> > Date: Sat, 13 Sep 2008 16:35:48 -0400
> > 
> > > Includes several fixes from my slice of the akpm patch pie.
> > 
> > Which of these have regression and/or bugzilla entries?
> > 
> > This is too much and I want to see it trimmed down.
> 
> What do you not want?  The two warning fixes (mlx4, cs89x0) akpm seemed
> to want in 2.6.27, the 8139too change is cosmetic.  The other stuff is
> critical AFAICS.

I'll take another look at the queue and try to give you some
more specific feedback.

I can think of about 3 or 4 entries on the posted regression
list that might be appropriate, so I essentially expected to
see that many commits, give or take one or two.
