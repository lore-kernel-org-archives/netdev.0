From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Thu, 13 Jan 2005 22:58:08 +0100
Message-ID: <20050113215808.GA15124@wohnheim.fh-wedel.de>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <20050106070245.GA6539@gate.ebshome.net> <61A37C72-659C-11D9-8D70-000393C30512@freescale.com> <20050113212152.GA16041@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>,
        Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20050113212152.GA16041@gate.ebshome.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 January 2005 13:21:52 -0800, Eugene Surovegin wrote:
>=20
> It's a standard, period. If there is a PHY which isn't compliant I
> guess it will not work anyway, but in this case, yes, we can use
> PHY-specific link detection, but only in this case. I suspect you'll
> have a hard time finding such PHY :)

http://www.broadcom.com/collateral/pb/5325-PB05-R.pdf

With some thinking and very little code, you can use this neat chip
almost like a normal phy.

J=F6rn

--=20
Optimizations always bust things, because all optimizations are, in
the long haul, a form of cheating, and cheaters eventually get caught.
-- Larry Wall=20
