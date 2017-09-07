From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 0/3] lan78xx: Fixes to lan78xx driver
Date: Thu, 7 Sep 2017 16:19:57 +0200
Message-ID: <20170907141957.GL11248@lunn.ch>
References: <CE371C1263339941885964188A0225FA333A58@CHN-SV-EXMX03.mchp-main.com>
 <20170907135909.GH11248@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40B1ADB7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nisar.Sayed@microchip.com, davem@davemloft.net,
        UNGLinuxDriver@microchip.com, netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59608 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754005AbdIGOUC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 10:20:02 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B1ADB7@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 07, 2017 at 02:03:38PM +0000, Woojung.Huh@microchip.com wrote:
> > On Thu, Sep 07, 2017 at 07:10:51AM +0000, Nisar.Sayed@microchip.com
> > wrote:
> > > From: Nisar Sayed <Nisar.Sayed@microchip.com>
> > >
> > > This series of patches are for lan78xx driver.
> > >
> > > These patches fixes potential issues associated with lan78xx driver
> > 
> > Hi Nisar
> > 
> > So this is version 2? Please include v2 in the subject line.
> > 
> > Also, briefly list what is different from the previous version.
> Hi Andrew,
> 
> Because Nisar dropped of non-mdio patch in the series,
> I suggested to treat as new patch than version 2.
> In this case, it is still considered as version 2 than new series?

Hi Woojung

So it is not a clear hard rule here. But we have seen these patches
before, and they have been modified based on my comments. So i would
say these are version 2. But a new series would also be O.K. What
really matters is that the cover note explains what is going on. That
some of the patches in the previous version have been dropped and will
be posted later, and what changes have been made to the remaining
patches.

   Andrew
