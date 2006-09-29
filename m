From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19 status
Date: Fri, 29 Sep 2006 00:48:54 -0700 (PDT)
Message-ID: <20060929.004854.104036222.davem@davemloft.net>
References: <20060928.184135.41635707.davem@davemloft.net>
	<200609291010.35025.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20910
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161489AbWI2Hsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 03:48:55 -0400
To: ismail@pardus.org.tr
In-Reply-To: <200609291010.35025.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ismail Donmez <ismail@pardus.org.tr>
Date: Fri, 29 Sep 2006 10:10:34 +0300

> Hi Dave,
> 29 Eyl 2006 Cum 04:41 tarihinde $,1 (Bunlar$,1 Q(B yazm$,1 Q (Bt$,1 Q(Bn$,1 Q(Bz:
> > I've just pushed my current net-2.6 tree to Linus.  The bulk of the
> > changes in there are endianness annotations for sparse by Al Viro,
> > along with the patches I've been ACK'ing here on the list and
> > elsewhere.
> >
> > If you want a non-bugfix change to get into 2.6.19 you must have it to
> > me by the end of the weekend.
> >
> > As of next Monday, anything I receive has to be a bugfix for 2.6.19
> > consideration.
> >
> > Thanks for everyone's hard work and let's make sure there are no
> > networking regressions at all in 2.6.19, in fact let's strive to
> > make it have no regressions plus bugs fixed that were in 2.6.18 :-)
> 
> Looks like following fix from Herbert still didn't made it to Linus which 
> fixes hard lockups with some tc usage.

It's in my net-2.6 tree, which is where you should check for
whether something is queued and pending submission yet.
