From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 09/15] net: can: Convert to use devm_ioremap_resource
Date: Mon, 10 Jun 2013 15:09:27 +0200
Message-ID: <51B5D007.8050005@pengutronix.de>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org> <1370864113-17895-10-git-send-email-tushar.behera@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2HOPDDRMHMUDPMUODDQBC"
Cc: linux-kernel@vger.kernel.org, thierry.reding@gmail.com,
	patches@linaro.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>
To: Tushar Behera <tushar.behera@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1370864113-17895-10-git-send-email-tushar.behera@linaro.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2HOPDDRMHMUDPMUODDQBC
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 06/10/2013 01:35 PM, Tushar Behera wrote:
> Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
> introduced devm_ioremap_resource() and deprecated the use of
> devm_request_and_ioremap().

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Are the patches going over the individual subsystem maintainers?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2HOPDDRMHMUDPMUODDQBC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlG10A0ACgkQjTAFq1RaXHOgrgCfc5EAxsxXoVlmBUx8FsblfoWg
oYQAn3dbgReZJpqQR7ynY5UYUwNzoot5
=z0Sn
-----END PGP SIGNATURE-----

------enig2HOPDDRMHMUDPMUODDQBC--
