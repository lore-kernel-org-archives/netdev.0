From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v4] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 22:28:36 +0100
Message-ID: <1298496516.2898.10.camel@edumazet-laptop>
References: <20110221160306.GA9650@tuxdriver.com>
	 <1298308283.2849.5.camel@edumazet-laptop>
	 <1298390536.2861.9.camel@edumazet-laptop>
	 <1298474091.3301.364.camel@edumazet-laptop>
	 <1298494577.2898.9.camel@edumazet-laptop> <20110223131158.632dc45c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49506 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542Ab1BWV2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 16:28:42 -0500
Received: by bwz15 with SMTP id 15so481140bwz.19
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 13:28:41 -0800 (PST)
In-Reply-To: <20110223131158.632dc45c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 13:11 -0800, Stephen Hemminger =
a =C3=A9crit :
> On Wed, 23 Feb 2011 21:56:17 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > +struct Qdisc_ops sfb_qdisc_ops __read_mostly =3D {
>=20
> Should be static?
>=20
>=20

Sure ! ;)


