From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Thu, 9 Jun 2011 23:23:28 +0300
Message-ID: <20110609202328.GD2857@acer>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <20110605083445.GT16318@ibawizard.net>
 <20110605085948.GB16018@acer>
 <20110605.140801.1144137337172959622.davem@davemloft.net>
 <20110606172607.GB3082@acer>
 <ADE657CA350FB648AAC2C43247A983F001F381FC56CE@AUSP01VMBX24.collaborationhost.net>
 <20110609195052.GB2857@acer>
 <ADE657CA350FB648AAC2C43247A983F001F3820B85E7@AUSP01VMBX24.collaborationhost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kernel@wantstofly.org" <kernel@wantstofly.org>,
	"rmallon@gmail.com" <rmallon@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"florian@openwrt.org" <florian@openwrt.org>,
	"ynezz@true.cz" <ynezz@true.cz>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52809 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755790Ab1FIUZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:25:55 -0400
Received: by eyx24 with SMTP id 24so674643eyx.19
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2011 13:25:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ADE657CA350FB648AAC2C43247A983F001F3820B85E7@AUSP01VMBX24.collaborationhost.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2011 at 03:18:39PM -0500, H Hartley Sweeten wrote:
> On Thursday, June 09, 2011 12:51 PM, Mika Westerberg wrote:
> > On Mon, Jun 06, 2011 at 12:48:19PM -0500, H Hartley Sweeten wrote:
> >> If Lennert is no longer maintaining the this driver we really need someone to
> >> step up and handle it.
> >> 
> >> I have no problem doing it but I really don't have a good grasp on the driver
> >> or the whole network subsystem.
> >> 
> >> If Lennert is willing to hand it over, I have no problem being listed as a
> >> co-maintainer along with either yourself of Ryan.  Between the two (or three)
> >> of us we should be able to handle it.
> >
> > Hartley,
> >
> > Can you take maintainership of this driver? Since you already maintain most of
> > the ep93xx core stuff I think that you are the right person for the job. If
> > you need any assistance I believe me and Ryan can help you out.
> >
> > We have now few patches queued:
> >	- this series from me to fix the DMA API violations
> >	- phylib patches from Florian Fainelli
> >
> > It would be great to get those in someday :-)
> 
> Hmm.. Ok, fine ;-)
> 
> I just submitted a patch to lkml changing the maintainership to myself.
> 
> Patches will still need to be applied through someone's tree, probably
> David Miller's, since I don't have my own.
> 
> I think your series and Florian's patches are still in my inbox.  I'll try
> to look at them today and provide feedback.

Ok, thanks :-)

I was also going to test and review Florian's patches this week. I'll report
back when I'm done.
