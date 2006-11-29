From: Dan Williams <dcbw@redhat.com>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Wed, 29 Nov 2006 10:21:09 -0500
Message-ID: <1164813669.2752.31.camel@localhost.localdomain>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
	 <200611291505.47405.mb@bu3sch.de>
	 <40f31dec0611290634h3c411c1am61c1b6bb60bc4866@mail.gmail.com>
	 <200611291612.33448.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nick Kossifidis <mickflemm@gmail.com>,
	Daniel Drake <ddrake@brontes3d.com>, netdev@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42989 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S967409AbWK2PTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 10:19:42 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200611291612.33448.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-29 at 16:12 +0100, Michael Buesch wrote:
> On Wednesday 29 November 2006 15:34, Nick Kossifidis wrote:
> > Good luck then ;-)
> > 
> > If anyone wants to help on making ar5k work with newer madwifi
> > versions and fix bugs etc (that 'll also help bsd ppl) plzz mail me.
> > We can make it better.
> > 
> > Nick
> > P.S. Why not work on dawifi ?
> 
> Because it won't be merged mainline either.

I thought dadwifi was supposed to replace net80211 with d80211 (but not
replace the binary HAL).  Aren't the two things complementary, or did
you just decide that starting from scratch would produce a less crufty,
better understood, better-d80211 integrated driver?

Dan

