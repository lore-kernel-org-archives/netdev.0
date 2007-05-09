From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 9 May 2007 12:35:40 +0200 (MEST)
Message-ID: <200705091035.l49AZeto017530@harpo.it.uu.se>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: buytenh@wantstofly.org, marcus@better.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:58145 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754737AbXEIKfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 06:35:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 May 2007 11:35:03 +0200, Marcus Better wrote:
> Lennert Buytenhek wrote:
> > Does that mean that the Debian ARM people have their heads so far
> > up their collective asses that they think that every form of change
> > is bad and are unable to accept that some forms of change might be
> > for the better?
> 
> Well, I am not one of the Debian ARM people, just a user... and I do hope the
> EABI port becomes supported in the future! But in the meatime there is a
> crowd of users running Debian on consumer devices like the NSLU2, and they
> need a LE network driver.

1) Development _should_ happen in small individually-manageable steps.
   It's wrong to delay integration of the new IXP4xx eth driver just
   because it's not yet LE-compatible.
2) LE Debian/ARM users do have alternatives: they can use USB-Ethernet
   adapters, for instance.

/Mikael
