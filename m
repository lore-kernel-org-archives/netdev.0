From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Wed, 29 Nov 2006 07:30:38 -0800
Message-ID: <20061129153038.GC5412@devicescape.com>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com> <200611291505.47405.mb@bu3sch.de> <40f31dec0611290634h3c411c1am61c1b6bb60bc4866@mail.gmail.com> <200611291612.33448.mb@bu3sch.de> <1164813669.2752.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>,
	Nick Kossifidis <mickflemm@gmail.com>,
	Daniel Drake <ddrake@brontes3d.com>, netdev@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:40674 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S967415AbWK2Paq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 10:30:46 -0500
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1164813669.2752.31.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 29, 2006 at 10:21:09AM -0500, Dan Williams wrote:
> On Wed, 2006-11-29 at 16:12 +0100, Michael Buesch wrote:
> > On Wednesday 29 November 2006 15:34, Nick Kossifidis wrote:
> > > Good luck then ;-)
> > > 
> > > If anyone wants to help on making ar5k work with newer madwifi
> > > versions and fix bugs etc (that 'll also help bsd ppl) plzz mail me.
> > > We can make it better.
> > > 
> > > Nick
> > > P.S. Why not work on dawifi ?
> > 
> > Because it won't be merged mainline either.
> 
> I thought dadwifi was supposed to replace net80211 with d80211 (but not
> replace the binary HAL). 

yes

>  Aren't the two things complementary, 

yes

> or did
> you just decide that starting from scratch would produce a less crufty,
> better understood, better-d80211 integrated driver?

well, dadwifi will be (is) well integrated with d80211.  As far as
cruft goes, I'd rather call it historical artifacts :-)  We are doing
our best to minimize cruft while standing on the shoulders of madwifi.

-David

> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
