From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [3.1-rc8 REGRESSION] sky2 hangs machine on turning off or
 suspending
Date: Wed, 23 Nov 2011 09:03:15 +0100
Message-ID: <1322035395.1298.50.camel@edumazet-laptop>
References: <CACna6ryTdLcWVYgHu=_mRFga1sFivpE_DyZOY-HMmKggkWAJAw@mail.gmail.com>
	 <CACna6rwDjqwypAr_03NEA=x8J_2DpL2LjgSMiQmLHHGv3AA7GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACna6rwDjqwypAr_03NEA=x8J_2DpL2LjgSMiQmLHHGv3AA7GA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 23 novembre 2011 =C3=A0 08:43 +0100, Rafa=C5=82 Mi=C5=82eck=
i a =C3=A9crit :

> The bug was resolved by:
> sky2: fix hang in napi_disable
>=20
> Stephen, two comments to you:
>=20
> 1) I really hoped to get some info about resolving this issue. You
> could just ping me that something worth testing was posted.
>=20

I agree 100%, I am verry sorry this happened.

Stephen, we must show toal respect to bug reporters, they do their part
of the job.

We need more bug reports :)

A "Reported-by:" tag is mandatory, not counting a CC on mails

As Rafal spent incredible time to bisect the bug, another tag is welcom=
e
as well :

"Bisected-by:" ...

This takes maybe 20 seconds, while the bug fix took far more...

> 2) Update your e-mail address in MAINTAINERS please.
>=20

What do you mean, it seems OK to me (Stephen Hemminger
<shemminger@vyatta.com>) ?
