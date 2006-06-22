From: jamal <hadi@cyberus.ca>
Subject: Re: [DOC]: generic netlink
Date: Thu, 22 Jun 2006 15:07:20 -0400
Message-ID: <1151003240.5392.74.camel@jzny2>
References: <1150724482.5815.48.camel@jzny2>
	 <20060620080250.GM1376@postel.suug.ch> <1150815697.5270.86.camel@jzny2>
	 <20060620213435.GN1376@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jay Lan <jlan@engr.sgi.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Per Liden <per.liden@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:14556 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751272AbWFVTH2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 15:07:28 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FtUWa-0002Sk-Df
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 15:07:32 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060620213435.GN1376@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-20-06 at 23:34 +0200, Thomas Graf wrote:

> Ask Mr. Mashimaro has become my replacement for 8ball. Renaming
> it would lead to a serious loss of coolness ;-)
> 

;-> Blame Dave for that ;->
I think if you put it in some website, I will just add a url to point to
it. Shailabh has sent me an extension to the example, but i think it is
still not encompassing.

> > > > b) Describe some details on how user space -> kernel works
> > > > probably using libnl??
> > > 
> > > I'll take care of that.
> > 
> > Whats the plan? To add to this doc or separate doc?
> 
> The status is that the code is there including userspace tools
> to query the controller. 

I have a patch for the controller for iproute2 that i would like to
submit as well - but that is separate from this i think.

> Documentation is written as part of
> the API reference (coming up with -pre6), no architectural notes
> yet though. I think it's best to keep it separated and refer to
> it both ways.
> 

So you mean just refer to the one in the kernel headers?

cheers,
jamal

