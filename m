From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 0/6] llc2: Simplify llc_station
Date: Tue, 18 Sep 2012 18:29:05 +0100
Message-ID: <20120918172905.GC29217@decadent.org.uk>
References: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
 <20120917.130531.941621987417626917.davem@davemloft.net>
 <20120917.131017.1646567691887140571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50426 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752083Ab2IRR3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 13:29:13 -0400
Content-Disposition: inline
In-Reply-To: <20120917.131017.1646567691887140571.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 17, 2012 at 01:10:17PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 17 Sep 2012 13:05:31 -0400 (EDT)
> 
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Sun, 16 Sep 2012 04:09:42 +0100
> > 
> >> There seem to have been some grand plans for llc_station, but as they
> >> haven't been fulfilled it's just unnecessarily complicated.
> > 
> > I went over these a few times, they look correct, so I am going
> > to apply them to net-next.
> > 
> > If there are any problems let's hope that exposure in the tree
> > helps shake those out.
> 
> It doesn't even build properly, please fix this and resubmit:
> 
> ERROR: "sysctl_llc_station_ack_timeout" [net/llc/llc2.ko] undefined!

Sorry, I was able to build net/llc/ successfully but didn't do a full
build which would have caught this.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
