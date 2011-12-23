From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 12:33:18 -0500
Message-ID: <1324661598.10184.615.camel@denise.theartistscloset.com>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324651128.10184.586.camel@denise.theartistscloset.com>
	 <1324652361.2223.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324654013.10184.597.camel@denise.theartistscloset.com>
	 <1324656963.4540.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324658658.10184.613.camel@denise.theartistscloset.com>
	 <1324659976.4540.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324660666.4540.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:57306 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757524Ab1LWRdX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 12:33:23 -0500
In-Reply-To: <1324660666.4540.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-23 at 18:17 +0100, Eric Dumazet wrote:
> Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 18:06 +0100, Eric Dumazet a =
=C3=A9crit :
>=20
> > Maybe I was not clear :
> >=20
> > netem currently uses a fifo queue, you cant change this, without
> > patching kernel.
> >=20
>=20
> An other way would be to patch sch_tbf, adding delay, if its all you
> want to do.
>=20
> (Or adding delay capability to ifb)
>=20
>=20
>=20
>=20
<grin> that's just a little outside by skill set ;) - John
