From: Doug Ledford <dledford@redhat.com>
Subject: Re: linux-next: manual merge of the rdma tree with the net-next tree
Date: Wed, 16 Mar 2016 13:35:28 -0400
Message-ID: <56E99960.5000604@redhat.com>
References: <20160316115809.61b4478e@canb.auug.org.au>
 <CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="A3qb41lanua6qe9x5Hqr6ab2BW3mhKr7u"
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Amir Vadai <amir@vadai.me>, Maor Gottlieb <maorg@mellanox.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--A3qb41lanua6qe9x5Hqr6ab2BW3mhKr7u
Content-Type: multipart/mixed; boundary="vfRDudjreIlOs2ODGMwQHemSFjla1XhAs"
From: Doug Ledford <dledford@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>
Cc: David Miller <davem@davemloft.net>,
 Network Development <netdev@vger.kernel.org>,
 linux-next <linux-next@vger.kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Amir Vadai <amir@vadai.me>, Maor Gottlieb <maorg@mellanox.com>
Message-ID: <56E99960.5000604@redhat.com>
Subject: Re: linux-next: manual merge of the rdma tree with the net-next tree
References: <20160316115809.61b4478e@canb.auug.org.au>
 <CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>
In-Reply-To: <CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>

--vfRDudjreIlOs2ODGMwQHemSFjla1XhAs
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 3/16/2016 1:18 PM, Linus Torvalds wrote:
> On Tue, Mar 15, 2016 at 5:58 PM, Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
>>
>> I fixed it up (see below) and can carry the fix as necessary (no actio=
n
>> is required).
>=20
> Side note: can you change this wording for your manual merge script?
> Last merge window (or was it the one before it?) we had confusion with
> people who thought that "no action is required" means "you can just
> ignore this entirely".

I certainly didn't take it that way regardless of the wording.  I'm
keenly aware of the short leash you have Mellanox (and by extension
myself) on.  I reviewed the merge in detail, enough to satisfy myself
that it was easy, correct, and that the code itself made the merge
obvious (such as the comment that flow table entries need to be last in
the lists in order to support priority transitions, which fairly handily
explained what needed to happen in the merge).




--vfRDudjreIlOs2ODGMwQHemSFjla1XhAs--

--A3qb41lanua6qe9x5Hqr6ab2BW3mhKr7u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJW6ZlgAAoJELgmozMOVy/dMgEQAMSpmIMm1IrQawsxD1jCx1W+
AIlvuTjpeKhClLpDNQ83xL3Zphl4Un+HSbjld/FezS8Lko/ncPqQzkPF2k+1h3NS
P2ZVTAln4W3OuvpQ1QCTzULa0Y+dITwG4OmM1cMeKlgfZgLZproVHkhuh/e4CXfc
g1rn44c9A6QtOkxe1MVSXPA4lf1NO40tnHlBIUPSHL8zFtG+G86vobBiutEhUyo/
FgHZT3vq8vvZB0iGs45S9mSRBzZ4OzdaXylkT4ywl0K7YGULSUqCsT41kQ/4OxIU
afGkudm0QFobKFwrxL33bXcc4L4yeB0NaJamq0cDmoyjviE1iXPxSVxZ3XAvcC5q
HnMsGBldfz08manW9quBXitxmknsY/3F7hA+VUH1ofnt1wo7RKc4l5QLOfXTt6cz
d2Mb0qV7lyHUunovKTL2TLYz2IqZxp2/kPaXmYAP7MLwj6dPivT1yJCfcw1B3rz7
qtbRfqnNRsPI8L7qeVl3L2wv4/4mK2OKYi2XTzfjAnvXdSpYdJhWyDmBTcnC5+W/
ZVT/bnIp+z7Cts7xFaBdBW/j8ZG/mvSptgpINXzB91QpzGyAsDUi8LPUjoqMQx8D
HxbF2AQP9SW9zHBRBCOnINDx3r0zSrOmqoWmM6orYEJm1rA4JTthUzbfCXfHetUR
W7V1EUW5qLNs1xGx3nYU
=aZjP
-----END PGP SIGNATURE-----

--A3qb41lanua6qe9x5Hqr6ab2BW3mhKr7u--
