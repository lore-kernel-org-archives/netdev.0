From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-2.6 PATCH 6/10] Neterion: New driver: Hardware init &configuration
Date: Tue, 17 Mar 2009 01:57:31 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705092E9B@nekter>
References: <1237018885.4966.431.camel@flash> <87bps12b33.fsf@basil.nowhere.org> <78C9135A3D2ECE4B8162EBDCE82CAD7705092E88@nekter> <1237260883.9656.23.camel@bunthorne.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Andi Kleen" <andi@firstfloor.org>,
	"Netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:4225 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461AbZCQF5h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 01:57:37 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1237260883.9656.23.camel@bunthorne.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,
Got it.

Thanks,
Ram

> -----Original Message-----
> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> Sent: Monday, March 16, 2009 8:35 PM
> To: Ramkrishna Vepa
> Cc: Andi Kleen; Netdev; David Miller
> Subject: RE: [net-2.6 PATCH 6/10] Neterion: New driver: Hardware init
> &configuration
> 
> On Mon, 2009-03-16 at 23:25 -0400, Ramkrishna Vepa wrote:
> > Andi,
> >
> > Thanks for the comments. We are looking into them.
> >
> > Question of the following -
> > > In general your driver looks like it could use a pass with
sparse's
> > > __iomem checking (make V=1)
> > How do I enable this checking?
> 
> What Andi said, only without the typo: run "make C=1
drivers/net/vxge/"
> 
> Ben.
> 
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
