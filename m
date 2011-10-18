From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v13 0/6] flexcan: Add support for powerpc flexcan
	(freescale p1010)
Date: Tue, 18 Oct 2011 13:48:10 +0200
Message-ID: <4E9D677A.3030706@pengutronix.de>
References: <1313551944-28603-1-git-send-email-holt@sgi.com>
	<16FBAA47-5133-43A1-80CE-C6D63B79FB5D@kernel.crashing.org>
	<20111018094328.GC22814@sgi.com>
	<D79CB818-C14E-4C8D-9A8D-42B39ADE20B2@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7530367968224969480=="
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D79CB818-C14E-4C8D-9A8D-42B39ADE20B2-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============7530367968224969480==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig33C0CCED0BB1A65EAAE88C6E"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig33C0CCED0BB1A65EAAE88C6E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/18/2011 01:43 PM, Kumar Gala wrote:
> Thanks, I'll look into this internally at FSL.  I think its confusing
> as hell to have "fsl,p1010-flexcan" in an ARM .dts and don't think
> any reasonable ARM customer of FSL would know to put a PPC SOC name
> in their .dts.  I'll ask the HW guys what's going on so we can come
> up with a bit more generic name so we don't have to constantly change
> this.  Even if its just:
>=20
> fsl,ppc-flexcan & fsl,arm-flexcan.

If you talk the HW guys ask them for a name for the coldfire flexcan
core, too please ;)

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig33C0CCED0BB1A65EAAE88C6E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6dZ3oACgkQjTAFq1RaXHM+EwCgmUMAlsrgCK7Kmoj/ONoZIDzY
/ocAnif9NwNKeyUhrLITqIHu+gJoxOq/
=5Hv0
-----END PGP SIGNATURE-----

--------------enig33C0CCED0BB1A65EAAE88C6E--

--===============7530367968224969480==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7530367968224969480==--
