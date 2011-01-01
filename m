From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Sat, 01 Jan 2011 22:40:16 +0100
Message-ID: <1293918016.28646.3.camel@wall-e>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
	 <1293789629.2973.26.camel@edumazet-laptop>
	 <1293790979.4787.10.camel@wall-e>
	 <1293792066.2973.43.camel@edumazet-laptop>
	 <1293794589.5285.16.camel@wall-e>
	 <1293796458.2973.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293796458.2973.59.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, den 31.12.2010, 12:54 +0100 schrieb Eric Dumazet:
> Le vendredi 31 d=E9cembre 2010 =E0 12:23 +0100, Stefani Seibold a =E9=
crit :
> > Am Freitag, den 31.12.2010, 11:41 +0100 schrieb Eric Dumazet:
> > > Le vendredi 31 d=E9cembre 2010 =E0 11:22 +0100, Stefani Seibold a=
 =E9crit :
> > > > Am Freitag, den 31.12.2010, 11:00 +0100 schrieb Eric Dumazet:
> > > > > Le vendredi 31 d=E9cembre 2010 =E0 10:29 +0100, stefani@seibo=
ld.net a
> > > > > =E9crit :
> > > > > > From: Stefani Seibold <stefani@seibold.net>
> > > > > >=20

> > > This is not how things are dealed in linux, really.
> > >=20
> > > You'll have to find a way so that things work well for everybody,=
 not
> > > only for you.
> > >=20
> > > I guess you must fix UDPCP protocol stack, not 'fix linux'
> > >=20
> >=20
> > I cannot fix it, because the information is still lost, and i need =
it.=20
> >=20
>=20
> You can fix it. Really. If not, you can pay me and I'll fix it for yo=
u.
>=20

I am a poor girl, so i did it by me self. Hope you like the new
approach.
