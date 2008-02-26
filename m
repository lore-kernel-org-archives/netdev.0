From: Olof Johansson <olof@lixom.net>
Subject: Re: [patch 0/6] pasemi_mac updates for 2.6.26
Date: Tue, 26 Feb 2008 12:33:42 -0600
Message-ID: <20080226183342.GA25225@lixom.net>
References: <20080221025753.903665000@lixom.net> <18371.57542.77446.443231@cargo.ozlabs.ibm.com> <20080226141624.GB22572@lixom.net> <47C4588C.5060904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pasemi-linux@ozlabs.org,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:34657 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071AbYBZS3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 13:29:31 -0500
Content-Disposition: inline
In-Reply-To: <47C4588C.5060904@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 01:21:00PM -0500, Jeff Garzik wrote:
> Olof Johansson wrote:
> > On Tue, Feb 26, 2008 at 08:49:58PM +1100, Paul Mackerras wrote:

> >> What route do you think these should take upstream?  I'm happy to take
> >> them if Jeff is OK with that.
> > 
> > I've sent them through Jeff in the past, that's been convenient when
> > there's been churn in the network APIs. I'm not sure if there's much of
> > that for .26 though.
> > 
> > If Jeff prefers to ACK, I'll just add it to my git and ask you to pull
> > that. But I was originally planning to just feed it through him.
> > 
> > (Note: I'll repost the patch set later today or tomorrow with a couple
> > of tweaks).
> 
> Not much networking churn for 2.6.26, and IMO this patchset have 
> above-average ppc changes/dependencies, so....   ACK

Ok, thanks Jeff.

Paul: I'll commit to my tree and ask you to pull later.


-Olof
