From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge extensions to iproute2
Date: Tue, 10 Jul 2012 14:58:21 -0700
Message-ID: <20120710145821.748c00be@nehalam.linuxnetplumber.net>
References: <CAHo-Ooyk_=UYsEtz-y6hupCtMOgKz2DF+j1BOnSsmAfm-5Bkqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34307 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247Ab2GJV6h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 17:58:37 -0400
In-Reply-To: <CAHo-Ooyk_=UYsEtz-y6hupCtMOgKz2DF+j1BOnSsmAfm-5Bkqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jul 2012 14:38:25 -0700
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> I can't quite seem to locate the bridge extensions to iproute2.
>=20
> Mentioned for example at:
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dco=
mmit;h=3Db078f0df676233fc7ebc1ab270bd11ef5824bb64
>=20
> I'm interested in finding a way to disable the stp and learning on a
> bridge and manually from userspace configuring the mac forwarding
> database.
> [for basically a userspace STP implementation, which wouldn't actuall=
y
> be a tree]
>=20
> Can this be done?
>=20
> Thanks,
>=20
> - Maciej

I will get back to these. There wasn't a motivation to go fast because
there wasn't a user of these. Now with fdb offload support they are nee=
ded.
