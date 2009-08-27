From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 7/7] MAINTAINERS: update information for sfc network
	driver
Date: Thu, 27 Aug 2009 13:23:19 +0100
Message-ID: <1251375799.2786.9.camel@achroite>
References: <1251310744.27345.21.camel@achroite>
	 <1251312467.13026.22.camel@Joe-Laptop.home>
	 <20090826.180445.102441324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:51783 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752433AbZH0MXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 08:23:23 -0400
In-Reply-To: <20090826.180445.102441324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-26 at 18:04 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 26 Aug 2009 11:47:47 -0700
> 
> > On Wed, 2009-08-26 at 19:19 +0100, Ben Hutchings wrote:
> >> Update the current maintainers and add our email addresses.  Robert
> >> Stonehouse has moved on to other projects.
> >> 
> >> Move the linux-net-drivers alias to the top since it should always
> >> reach the current maintainers at Solarflare.  Add netdev as the
> >> relevant mailing list.
> > []
> >> +M:	linux-net-drivers@solarflare.com (alias for current maintainers)
> > 
> > Hi Ben
> > 
> > This form: "M:	bare address (extra stuff)" doesn't work
> > with the get_maintainers script.
> > 
> > Can you please use something like this instead?
> > 
> > M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
> > 
> > Perhaps this diff below.
> 
> Joe's version seems based upon reasonable requests, so I've
> applied his diff.
> 
> Thanks.

Ack, and thanks.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

