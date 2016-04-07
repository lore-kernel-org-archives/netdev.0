From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Date: Thu, 7 Apr 2016 21:43:46 +0200
Message-ID: <20160407214346.15d257d3@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<2816CC0C-686E-43CA-8689-027085255703@oracle.com>
	<1460045640.30063.3.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/C+RflKLr9orIH8g0NeUE4IW"; protocol="application/pgp-signature"
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig
 <hch@infradead.org>,
        James Bottomley
 <James.Bottomley@HansenPartnership.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org,
        linux-mm <linux-mm@kvack.org>,
        "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>,
        lsf-pc@lists.linux-foundation.org,
        Alexei
 Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com
To: Rik van Riel <riel@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1460045640.30063.3.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

--Sig_/C+RflKLr9orIH8g0NeUE4IW
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable


On Thu, 07 Apr 2016 12:14:00 -0400 Rik van Riel <riel@redhat.com> wrote:

> On Thu, 2016-04-07 at 08:48 -0700, Chuck Lever wrote:
> > >=20
> > > On Apr 7, 2016, at 7:38 AM, Christoph Hellwig <hch@infradead.org>
> > > wrote:
> > >=20
> > > This is also very interesting for storage targets, which face the
> > > same issue.=C2=A0=C2=A0SCST has a mode where it caches some fully con=
structed
> > > SGLs, which is probably very similar to what NICs want to do. =20
> >
> > +1 for NFS server. =20
>=20
> I have swapped around my slot (into the MM track)
> with Jesper's slot (now a plenary session), since
> there seems to be a fair amount of interest in
> Jesper's proposal from IO and FS people, and my
> topic is more MM specific.

Wow - I'm impressed. I didn't expect such a good slot!
Glad to see the interest!
Thanks!

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--Sig_/C+RflKLr9orIH8g0NeUE4IW
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iF4EAREIAAYFAlcGuHIACgkQOlVNAzs3vO1BBwD/R86hwonrHFC8s7sywSW+8xSl
n5OG2+3SgNkIsCtNnQgA/RUMejhP+lE7cOeLuiRDS9Pk9489jVXW2XqRYZZLFfCC
=W3yv
-----END PGP SIGNATURE-----

--Sig_/C+RflKLr9orIH8g0NeUE4IW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
