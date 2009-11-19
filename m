From: Greg KH <greg@kroah.com>
Subject: Re: wanPMC-CxT1E1
Date: Thu, 19 Nov 2009 14:25:51 -0800
Message-ID: <20091119222551.GA18710@kroah.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
 <20091026204144.GA28436@kroah.com>
 <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
 <m3d4454phz.fsf@intrepid.localdomain>
 <4f6ba3b0911021241gb6d9684ga76228013e0f5f14@mail.gmail.com>
 <20091102205911.GA23443@kroah.com>
 <4f6ba3b0911021316v16ff7431s4dfa939743541df6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Bob Beers <bob.beers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:41166 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756398AbZKSXGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 18:06:54 -0500
Content-Disposition: inline
In-Reply-To: <4f6ba3b0911021316v16ff7431s4dfa939743541df6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2009 at 04:16:25PM -0500, Bob Beers wrote:
> >>
> >> commit d54e08030785153c8c0f4eb4f1cf320d60fff286
> >> Author: Bob Beers <bob.beers@gmail.com>
> >> Date: =A0 Mon Nov 2 15:06:19 2009 -0500
> >>
> >> =A0 =A0 Add CXT1E1 [1,2,4] channel wan card driver.
> >>
> >> =A0drivers/net/wan/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A01 +
> >
> > This file shouldn't need to be modified. =A0But I can fix that up b=
y hand.
> >
>=20
> Yeah, sorry about that.

Sorry for the long delay, my fault :(

Anyway, I need a "Signed-off-by:" line for the patch so that I can appl=
y
it.  Also, who is the original author of the driver, any ideas?  We
should at least credit them with this, right?

Can you resend with a signed-off-by: line, and the other fixes all
rolled up into one patch?

thanks,

greg k-h
