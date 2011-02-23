From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v4] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 13:30:12 -0800 (PST)
Message-ID: <20110223.133012.189717067.davem@davemloft.net>
References: <1298494577.2898.9.camel@edumazet-laptop>
	<20110223131158.632dc45c@nehalam>
	<1298496516.2898.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, Juliusz.Chroboczek@pps.jussieu.fr,
	linville@tuxdriver.com, kaber@trash.net, netdev@vger.kernel.org,
	andi@firstfloor.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50153
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753467Ab1BWV3g convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 16:29:36 -0500
In-Reply-To: <1298496516.2898.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Feb 2011 22:28:36 +0100

> Le mercredi 23 f=E9vrier 2011 =E0 13:11 -0800, Stephen Hemminger a =E9=
crit :
>> On Wed, 23 Feb 2011 21:56:17 +0100
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>=20
>> > +struct Qdisc_ops sfb_qdisc_ops __read_mostly =3D {
>>=20
>> Should be static?
>>=20
>>=20
>=20
> Sure ! ;)

I can make this simple fixup when I apply the patch to net-next-2.6,
Eric you don't have to respin it just for this.
