From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] i40e: constify i40e_client_ops structure
Date: Fri, 13 May 2016 12:50:02 -0400
Message-ID: <0c2df9ca-64bd-ac73-9071-f4d619887df8@redhat.com>
References: <1462104443-30724-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="KIq23I7uJlgtpVQ3upPcLUR6LFqpNk20Q"
Cc: kernel-janitors@vger.kernel.org, linux-rdma@vger.kernel.org,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
	Shiraz Saleem <shiraz.saleem@intel.com>,
	Mustafa Ismail <mustafa.ismail@intel.com>,
	Chien Tin Tung <chien.tin.tung@intel.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462104443-30724-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KIq23I7uJlgtpVQ3upPcLUR6LFqpNk20Q
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/01/2016 08:07 AM, Julia Lawall wrote:
> The i40e_client_ops structure is never modified, so declare it as const=
=2E
>=20
> Done with the help of Coccinelle.
>=20
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Thanks, applied.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--KIq23I7uJlgtpVQ3upPcLUR6LFqpNk20Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNgW6AAoJELgmozMOVy/dOV0P/0iVg0kXe+OFbLc5ujtbRv39
PfCWAClChayvvw88B4yD2vSAAGSvYpQf3qcCJpajbbpupatlU9+HMXMT0Ii8KIxK
+eF6kjR4PwH6+IpVqHQT7ct9A8odATVfTfkxQoN0VsRZjNUQe4sCKie9iIH40V8O
oSPkpR3ttPuPLofjx6mVFIJkGxMKXzGVwJSyPcn3AedCQP2Ose54io3oIkP3/RR4
BhjdEV95PVVQmhzl3eTCxE0eA1egQ7z9p/VO/uPE/6YBhjlraBchAMmJgARITxGO
pYzimvnsOVAqx2omxx+5i5Xg/lkWl4MqXQIMY++RUCmQVn8XLhIeS1AqIivamKXa
RjJzQFynowtkvVKpwZJ0XUK2PmW5jT9KdfKKQjQ3ymFM2FXHJHbHHFlJp5NvtHfm
eM1F5goWMBwoL2ne40vUZObim7yRHAL7feAnb65qORmmYnSxyGytPOTchWbEw4E6
UhjkErNWKGp5MqllLCrLYmwa6x8S5rHBoR6tTW2b/HcnjGeYwbA0TeODj31Sxr89
qV5qohdwluhCFzNtCUXZY6jy2aqvlcjFGLfvSmTrcDERxDtlsvJbaje7/rOnIf9N
GZtXz7Vbkd9HRtegSktmEub6ynN7QYnD7PgYg3ykqpQWeRbBHa3MS5yOHEGimsZp
BQw+po00sWvDxPenfRVq
=A+KN
-----END PGP SIGNATURE-----

--KIq23I7uJlgtpVQ3upPcLUR6LFqpNk20Q--
