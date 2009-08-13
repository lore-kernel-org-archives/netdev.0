From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: AlacrityVM numbers updated for 31-rc4
Date: Thu, 13 Aug 2009 08:05:06 -0400
Message-ID: <4A840172.8020707@gmail.com>
References: <4A83296B.3080606@gmail.com> <4A834ABB.4010801@codemonkey.ws> <4A834E75.9060204@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig21D5013D96877AA48AB44C19"
Cc: alacrityvm-devel@lists.sourceforge.net,
	alacrityvm-users@lists.sourceforge.net,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754095AbZHMMFP@vger.kernel.org>
In-Reply-To: <4A834E75.9060204@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig21D5013D96877AA48AB44C19
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gregory Haskins wrote:
> Anthony Liguori wrote:

>> Just FYI, the numbers quoted are wrong for virtio-u.  Greg's machine
>> didn't have high res timers enabled in the kernel.  He'll post newer
>> numbers later but they're much better than these (venet is still ahead=

>> though).
>>
>> Regards,
>>
>> Anthony Liguori
>=20
> Anthony is correct.  The new numbers after fixing the HRT clock issue a=
re:
>=20
> virtio-u: 2670Mb/s, 266us rtt (3764 tps udp-rr)
>=20
> I will update the charts later tonight.
>=20

done


--------------enig21D5013D96877AA48AB44C19
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqEAXIACgkQP5K2CMvXmqEhtwCfcSwKKYWysNLQmF7VISNrNPwl
CkIAniQ8z8sQcIkd/hdeXQhfHuxx1TIa
=jRLu
-----END PGP SIGNATURE-----

--------------enig21D5013D96877AA48AB44C19--
