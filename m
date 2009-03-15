From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-2.6 PATCH 3/10] Neterion: New driver: Kconfig and Makefile
Date: Sun, 15 Mar 2009 18:42:12 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705092C4A@nekter>
References: <1237018842.4966.418.camel@flash> <1237144179.4209.31.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:14010 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754939AbZCOWmQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 18:42:16 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1237144179.4209.31.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

Thanks for the comments. We will address them when we resubmit the
patches in the next day or so.

Ram

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Ben Hutchings
> Sent: Sunday, March 15, 2009 12:10 PM
> To: ram.vepa@neterion.com
> Cc: Netdev; David Miller
> Subject: Re: [net-2.6 PATCH 3/10] Neterion: New driver: Kconfig and
> Makefile
> 
> On Sat, 2009-03-14 at 00:20 -0800, Ramkrishna Vepa wrote:
> > - Kconfig and Makefile related changes for vxge driver.
> [...]
> 
> These should really come last in the series so they don't refer to
> nonexistent files.  This may not matter for a new driver as Dave can
> squash them together into one patch.
> 
> Ben.
> 
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
