From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] watch64: generic variable monitoring system
Date: 07 Sep 2004 06:18:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094460391.1151.26.camel@jzny.localdomain>
References: <200409031307.01240.jeffpc@optonline.net>
	 <200409031744.32970.jeffpc@optonline.net>
	 <1094303999.1633.116.camel@jzny.localdomain>
	 <200409051219.47590.jeffpc@optonline.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Sipek <jeffpc@optonline.net>
In-Reply-To: <200409051219.47590.jeffpc@optonline.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sun, 2004-09-05 at 12:19, Jeff Sipek wrote:
> On Saturday 04 September 2004 09:19, jamal wrote:
> > I have a feeling this was discussed somewhere(other than netdev) and i
> > missed it. Why isnt this watch64 being done in user space?
> 
> There was a discussion about 64-bit network statistics about a year ago on 
> lkml.

Sorry unsubscribed from lkml since summer of '94. [net related
discussions should really happen on netdev].

> watch64 is a generic so that anyone in the kernel can use it.

Ok - so why does this have to be in the kernel?

cheers,
jamal
