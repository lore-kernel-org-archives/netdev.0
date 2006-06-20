From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [DOC]: generic netlink
Date: Tue, 20 Jun 2006 23:34:35 +0200
Message-ID: <20060620213435.GN1376@postel.suug.ch>
References: <1150724482.5815.48.camel@jzny2> <20060620080250.GM1376@postel.suug.ch> <1150815697.5270.86.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Per Liden <per.liden@ericsson.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Jay Lan <jlan@engr.sgi.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45526 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751199AbWFTVeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 17:34:15 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1150815697.5270.86.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

> > > TODO:
> > > a) Add a more complete compiling kernel module with events.
> > > Have Thomas put his Mashimaro example and point to it.
> > 
> > I guess we have a legal issue here ;)
> > 
> 
> change the name ;->

Ask Mr. Mashimaro has become my replacement for 8ball. Renaming
it would lead to a serious loss of coolness ;-)

> > > b) Describe some details on how user space -> kernel works
> > > probably using libnl??
> > 
> > I'll take care of that.
> 
> Whats the plan? To add to this doc or separate doc?

The status is that the code is there including userspace tools
to query the controller. Documentation is written as part of
the API reference (coming up with -pre6), no architectural notes
yet though. I think it's best to keep it separated and refer to
it both ways.

