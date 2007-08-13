From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] [70/2many] MAINTAINERS - ARPD SUPPORT
Date: Mon, 13 Aug 2007 08:46:06 -0700
Message-ID: <1187019966.10249.75.camel@localhost>
References: <46bff8e8.HhTQ7TBPy1zkcNfh%joe@perches.com>
	 <20070813114942.04a5483c@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3063 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967516AbXHMPqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 11:46:48 -0400
In-Reply-To: <20070813114942.04a5483c@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-13 at 11:49 +0100, Alan Cox wrote:
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index 90c1b81..ac2226b 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -697,6 +697,7 @@ ARPD SUPPORT
> >  P:	Jonathan Layes
> >  L:	netdev@vger.kernel.org
> >  S:	Maintained
> > +F:	net/ipv4/arp.c
> 
> NAK
> 
> arp.c is the netdev people, ARPD is a corner case bit of code within it,
> something your patterns don't actually cope with

Suggestions?

