From: Tom Duffy <tduffy@sun.com>
Subject: Re: [PATCH][v3][17/21] Add IPoIB
	(IP-over-InfiniBand) driver
Date: Mon, 13 Dec 2004 10:44:24 -0800
Message-ID: <1102963464.9258.11.camel@duffman>
References: <20041213109.JT1ejUdkRIUXbWOm@topspin.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0951564687=="
Cc: netdev@oss.sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <20041213109.JT1ejUdkRIUXbWOm@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


--===============0951564687==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-+Gg/yNtd8JYVNcpHnKZq"


--=-+Gg/yNtd8JYVNcpHnKZq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2004-12-13 at 10:09 -0800, Roland Dreier wrote:
> --- linux-bk.orig/drivers/infiniband/Kconfig	2004-12-13 09:44:43.93625277=
9 -0800
> +++ linux-bk/drivers/infiniband/Kconfig	2004-12-13 09:44:49.385450009 -08=
00
> @@ -2,7 +2,6 @@
> =20
>  config INFINIBAND
>  	tristate "InfiniBand support"
> -	default n
>  	---help---
>  	  Core support for InfiniBand (IB).  Make sure to also select
>  	  any protocols you wish to use as well as drivers for your

Is there a reason why you put this in in an earlier patch and then take
it out later?

-tduffy

--=-+Gg/yNtd8JYVNcpHnKZq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBveMIdY502zjzwbwRAuywAKCbVtRdF/PW+JhPLjveoWFGzCKrhACgjoqK
64lZj1fH0R7rZbF+pAmN4MI=
=VJFe
-----END PGP SIGNATURE-----

--=-+Gg/yNtd8JYVNcpHnKZq--

--===============0951564687==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0951564687==--
