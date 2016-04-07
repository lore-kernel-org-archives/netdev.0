From: Rik van Riel <riel@redhat.com>
Subject: Re: [Lsf-pc] [Lsf] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Date: Thu, 07 Apr 2016 12:14:00 -0400
Message-ID: <1460045640.30063.3.camel@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com> <20160407143854.GA7685@infradead.org>
	 <2816CC0C-686E-43CA-8689-027085255703@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-UsUylZjyd8DzUzsJ2NSn"
Cc: lsf@lists.linux-foundation.org, Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        James Bottomley
 <James.Bottomley@HansenPartnership.com>,
        linux-mm <linux-mm@kvack.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jesper Dangaard Brouer
 <brouer@redhat.com>,
        lsf-pc@lists.linux-foundation.org,
        Alexei Starovoitov
 <alexei.starovoitov@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig
 <hch@infradead.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <2816CC0C-686E-43CA-8689-027085255703@oracle.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


--=-UsUylZjyd8DzUzsJ2NSn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-04-07 at 08:48 -0700, Chuck Lever wrote:
> >=20
> > On Apr 7, 2016, at 7:38 AM, Christoph Hellwig <hch@infradead.org>
> > wrote:
> >=20
> > This is also very interesting for storage targets, which face the
> > same
> > issue.=C2=A0=C2=A0SCST has a mode where it caches some fully constructe=
d
> > SGLs,
> > which is probably very similar to what NICs want to do.
> +1 for NFS server.

I have swapped around my slot (into the MM track)
with Jesper's slot (now a plenary session), since
there seems to be a fair amount of interest in
Jesper's proposal from IO and FS people, and my
topic is more MM specific.

--=20
All Rights Reversed.


--=-UsUylZjyd8DzUzsJ2NSn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXBodIAAoJEM553pKExN6D454IALC5jqiIbLVMGRBwiOvNBus+
1dylF98TNkuiHOqurG/X5ipRmisWO61uhls/64+jWBz6GhwWCPw456rM7WGoNEK6
ewEuVuspKTJqkTDcek5bLUE3a3QznfZMO2NnIVi2s+VNfIL+23fWNxDO2S5YN08P
x0Ru6FDzqAm6pqmddIgka+463utaKS7OMpbC6ak0aFNGh/LDmEHXb5Ap6OZ6gHKY
OgF8Ce7Acd51ISRRa6wgIR3PYjgYBhJidSPmbbDtYkYjr/7N7tqVa9gnz0wa45yK
oj2MpG2WBr4fhGMD0C3f+sZS2KqcOs6Pl1hB7tkce/XMXi6n7FsPPOwtywsHIaA=
=lFk5
-----END PGP SIGNATURE-----

--=-UsUylZjyd8DzUzsJ2NSn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
