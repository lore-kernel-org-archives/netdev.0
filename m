From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: VJ Channel API - driver level (PATCH)
Date: Sat, 6 May 2006 12:57:06 +0400
Message-ID: <20060506085706.GA22324@2ka.mipt.ru>
References: <445A84E7.1060906@neterion.com> <20060504.160432.48902082.davem@davemloft.net> <20060505093656.GB23540@2ka.mipt.ru> <20060505.173533.55820251.davem@davemloft.net> <20060506084238.GB16558@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: alex@neterion.com, caitlinb@broadcom.com,
	Leonid.Grossman@neterion.com, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45225 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750963AbWEFI50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 May 2006 04:57:26 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060506084238.GB16558@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 06, 2006 at 12:42:38PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Fri, May 05, 2006 at 05:35:33PM -0700, David S. Miller (davem@davemloft.net) wrote:
> > From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> > Date: Fri, 5 May 2006 13:36:56 +0400
> > 
> > > Hardware folks could also create it's own implementation and show
> > > community if theirs approach is good or not.
> > 
> > Designing hardware for non-existing software infrastructure is
> > risky buisness :-)
> 
> There are companies that do TOE and crypto accelerators without
> support from even windows :)

And actually most of them have research departments which do new
interesting developments.

It is Open Source after all - just do everything you want and show
community that it is usefull. Neterion did that right with UFO and LRO.

IBM started to do it with netchannels.

-- 
	Evgeniy Polyakov
