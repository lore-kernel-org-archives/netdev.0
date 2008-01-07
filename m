From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Mon, 07 Jan 2008 13:56:21 -0800 (PST)
Message-ID: <20080107.135621.259663114.davem@davemloft.net>
References: <Pine.SOC.4.64.0712271327030.20202@math.ut.ee>
	<47738F31.20304@garzik.org>
	<Pine.SOC.4.64.0801071443390.28077@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752689AbYAGV4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 16:56:22 -0500
In-Reply-To: <Pine.SOC.4.64.0801071443390.28077@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Mon, 7 Jan 2008 14:44:03 +0200 (EET)

> > > JG> A couple [minorly] notable wireless bug fixes, and plenty of viro fixes
> > > JG> for obscure issues :)
> > > 
> > > What about the tulip NAPI fix from Stephen Hemminger? Without this, my tulip
> > > is hosed easily.
> > > 
> > > The thread where I reported it was "Badness at net/core/dev.c:2199", around
> > > Dec 16.
> > 
> > That's going up in the first post-Xmas batch.
> 
> Well, it's 2.6.24-rc7 already - any news?

I put this into my net-2.6 tree last night since Jeff asked
me to look over critical networking driver stuff for a little
while.
