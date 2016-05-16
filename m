From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Mon, 16 May 2016 14:04:15 -0400 (EDT)
Message-ID: <20160516.140415.1976709754133870798.davem@davemloft.net>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20160516.132307.165371654494650235.davem@davemloft.net>
	<573A0388.2010002@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, afd-l0cyMroinI0@public.gmane.org,
	nm-l0cyMroinI0@public.gmane.org
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <573A0388.2010002-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 16 May 2016 10:29:44 -0700

> On 05/16/2016 10:23 AM, David Miller wrote:
>> From: Uwe Kleine-K=F6nig <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> Date: Thu, 12 May 2016 12:00:33 +0200
>>=20
>>> The framework only asserts (for now) that the reset gpio is not act=
ive.
>>>
>>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>=20
>> Applied.
>=20
> Humm that was a little too quick IMHO, there are two concurrent patch=
es
> adressing the same problem right now, and Uwe's patch relies on a
> specific "quirk" of specifying the Ethernet PHY's full OUI in the Dev=
ice
> Tree compatible string, while Sergei's approach does not require that=
=2E..
> AFAICT, the binding portion of the patch was also still being discuss=
ed.
>=20
> I guess we will have to submit incremental patches now.

Sorry, I thought this one had been resolved. :-/

There is still a lot of time to correct this, don't worry.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
