From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] MAINTAINERS: add myself as Renesas Ethernet drivers
 reviewer
Date: Fri, 04 Dec 2015 16:41:03 -0800
Message-ID: <1449276063.8611.25.camel@perches.com>
References: <1846877.jRW8849mPU@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1846877.jRW8849mPU@wasted.cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-12-05 at 03:03 +0300, Sergei Shtylyov wrote:
> liAdd myself as=A0=A0a reviewer for the Renesas Ethernet drivers --
> hopefully I
> won't miss the buggy=A0=A0patches anymore. :-)
>=20
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
> ---
> The patch is against DaveM's 'net.git' repo.
>=20
> =A0MAINTAINERS |=A0=A0=A0=A08 ++++++++
> =A01 file changed, 8 insertions(+)
>=20
> Index: net/MAINTAINERS
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net.orig/MAINTAINERS
> +++ net/MAINTAINERS
> @@ -8929,6 +8929,14 @@ F:	drivers/rpmsg/
> =A0F:	Documentation/rpmsg.txt
> =A0F:	include/linux/rpmsg.h
> =A0
> +RENESAS ETHERNET DRIVERS
> +R:	Sergei Shtylyov <serge.shtylyov@cogentembedded.com>
> +L:	netdev@vger.kernel.orgc
> +L:	linux-sh@vger.kernel.org
> +S:	Maintained
> +F:	drivers/net/ethernet/renesas/
> +F:	include/linux/sh_eth.h

Hello Sergei

Typically a reviewer isn't a maintainer.
Does anyone actually maintain this?

I suggest you mark this "S: Odd fixes" or
remove the "S:" line altogether unless you
really want to become the maintainer.
