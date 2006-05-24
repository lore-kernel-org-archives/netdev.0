From: Martin Hicks <mort@bork.org>
Subject: Re: r8169 cardbus device naming weirdness
Date: Wed, 24 May 2006 15:13:06 -0400
Message-ID: <20060524191306.GA23153@bork.org>
References: <20060523174402.GG29687@bork.org> <20060523105108.7c0e2367@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from galileo.bork.org ([134.117.69.57]:55011 "EHLO galileo.bork.org")
	by vger.kernel.org with ESMTP id S1751226AbWEXTNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 15:13:07 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060523105108.7c0e2367@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, May 23, 2006 at 10:51:08AM -0700, Stephen Hemminger wrote:
> 
> Most likely some user space script is renaming it.
> Each distro seems to have it's own way of doing configuration, and most
> do something in response to the hotplug event from device registration.
> So it was eth1 until what ever ran in response to the hotplug event
> decide to change it.

of course you're right.

/me fist shakes at udev

mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE
