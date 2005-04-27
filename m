From: Domen Puncer <domen@coderock.org>
Subject: Re: [KJ] [PATCH] Documentation/networking/dmfe.txt : Make
	documentation nicer
Date: Wed, 27 Apr 2005 19:07:04 +0200
Message-ID: <20050427170703.GA3762@nd47.coderock.org>
References: <200504262244.01258.ismail@kde.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: kernel-janitors@lists.osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: Ismail Donmez <ismail@kde.org.tr>
Content-Disposition: inline
In-Reply-To: <200504262244.01258.ismail@kde.org.tr>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On 26/04/05 22:44 +0300, Ismail Donmez wrote:
> Hi,
>=20
> attached patch indents dmfe.txt to look like other docs. It adds a tip =
about=20
> CNET cards using Davicom chipsets. Also it removes parts where it refer=
s to=20
> how to build driver out-of-kernel which seems to be cruft from times wh=
ere=20
> the driver was out of the kernel.

Please, no quoted-printable, it makes it hard for scripts to parse right.
(=3D20 and similar "characters")

>=20
> Signed-off-by: ??smail D=F6nmez <ismail@kde.org.tr>

Uhh... I don't recall being discussed in which encoding this should be,
ascii is a safe bet.

> --- dmfe.txt	2004-07-24 09:45:13.000000000 +0300
> +++ dmfe2.txt	2004-07-24 09:46:37.000000000 +0300

Patch should be -p1 appliable... meaning these lines will be something li=
ke:
--- linux-2.6.12-rc3/Documentation/dmfe.txt ...
+++ linux-dev/Documentation/dmfe.txt ...

> @@ -1,59 +1,65 @@
> -  dmfe.c: Version 1.28        01/18/2000
> +Davicom DM9102(A)/DM9132/DM9801 fast ethernet driver for Linux.=20

Trailing whitespace.
