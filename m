From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: regression: wireless authentication
Date: Mon, 20 Jul 2009 10:59:34 -0400
Message-ID: <20090720145934.GD2775@tuxdriver.com>
References: <20090717035706.GA5923@martini> <20090717141047.7ce77136.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Noah Watkins <jayhawk@soe.ucsc.edu>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34268 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbZGTPA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 11:00:58 -0400
Content-Disposition: inline
In-Reply-To: <20090717141047.7ce77136.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2009 at 02:10:47PM +1000, Stephen Rothwell wrote:
> Hi Noah,
>=20
> Lets cc some people who may be able to help ...
>=20
> On Thu, 16 Jul 2009 20:57:06 -0700 Noah Watkins <jayhawk@soe.ucsc.edu=
> wrote:
> >
> > With 2.6.31-rc3-next-20090716 all wireless access points are detect=
ed, but
> > authentication fails. I haven't verified on an access point w/o WPA=
=2E
> >=20
> > 2.6.31-rc3 functions fine. I haven't been able to complete a bisect=
 yet.
> >=20
> > 05:01.0 Network controller: Atheros Communications Inc. AR5008 Wire=
less Network
> > Adapter (rev 01)

Odd...have you (i.e. Noah) been using -next trees all along?  What was
the last previous one that worked?  I didn't push anything out for
-next to pick-up all last week...

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
			=A1Viva Honduras Libre!
