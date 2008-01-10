From: Meelis Roos <mroos@linux.ee>
Subject: Re: [git patches] net driver fixes
Date: Thu, 10 Jan 2008 11:24:24 +0200 (EET)
Message-ID: <Pine.SOC.4.64.0801101123150.2163@math.ut.ee>
References: <Pine.SOC.4.64.0712271327030.20202@math.ut.ee> <47738F31.20304@garzik.org>
 <Pine.SOC.4.64.0801071443390.28077@math.ut.ee> <20080107.135621.259663114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:40871 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbYAJJY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 04:24:26 -0500
In-Reply-To: <20080107.135621.259663114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Well, it's 2.6.24-rc7 already - any news?
> 
> I put this into my net-2.6 tree last night since Jeff asked
> me to look over critical networking driver stuff for a little
> while.

Thanks, they are upstream now and it did fix tulip in my PPC - network 
is stable again.

-- 
Meelis Roos (mroos@linux.ee)
