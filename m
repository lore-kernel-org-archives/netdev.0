From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 19:16:14 +0100
Message-ID: <1340216174.2576.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120619.175435.1705108432673390966.davem@davemloft.net>
	 <1340154206.6871.90.camel@deadeye.wl.decadent.org.uk>
	 <20120619.180527.65196005824751590.davem@davemloft.net>
	 <20120619.190202.2133868658770269780.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:61217 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754546Ab2FTSQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 14:16:17 -0400
In-Reply-To: <20120619.190202.2133868658770269780.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 19:02 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 19 Jun 2012 18:05:27 -0700 (PDT)
> 
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Wed, 20 Jun 2012 02:03:26 +0100
> > 
> >> On Tue, 2012-06-19 at 17:54 -0700, David Miller wrote:
> >>> The hash is perfect, what's the big deal?
> >> 
> >> It obscures what we're really doing and relying on.
> > 
> > If it matters to you, patches are always welcome :-)
> 
> Nevermind, I just committed the following to net-next:
[...]

Thanks very much, David.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
