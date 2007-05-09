From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 9 May 2007 13:07:59 +0200
Message-ID: <20070509110759.GB7513@xi.wantstofly.org>
References: <200705091035.l49AZeto017530@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcus@better.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:51726 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757306AbXEILIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 07:08:01 -0400
Content-Disposition: inline
In-Reply-To: <200705091035.l49AZeto017530@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 09, 2007 at 12:35:40PM +0200, Mikael Pettersson wrote:

> > > Does that mean that the Debian ARM people have their heads so far
> > > up their collective asses that they think that every form of change
> > > is bad and are unable to accept that some forms of change might be
> > > for the better?
> > 
> > Well, I am not one of the Debian ARM people, just a user... and I
> > do hope the EABI port becomes supported in the future! But in the
> > meatime there is a crowd of users running Debian on consumer devices
> > like the NSLU2, and they need a LE network driver.
> 
> 1) Development _should_ happen in small individually-manageable steps.
>    It's wrong to delay integration of the new IXP4xx eth driver just
>    because it's not yet LE-compatible.

Exactly.


> 2) LE Debian/ARM users do have alternatives: they can use USB-Ethernet
>    adapters, for instance.

Or just use Christian's driver.
