From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the ipsec-next tree with the
 net-next tree
Date: Fri, 27 Sep 2013 12:01:07 +1000
Message-ID: <20130927120107.99925373bcc260b50e0b3ed8@canb.auug.org.au>
References: <20130924121629.f818475ddf308b0494cfce2a@canb.auug.org.au>
	<20130924102505.GS7660@secunet.com>
	<20130925095919.143635403832766c1b190202@canb.auug.org.au>
	<20130925052923.GU7660@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__27_Sep_2013_12_01_07_+1000_Bpt5QyrZT9zDdR=2"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Fan Du <fan.du@windriver.com>, Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130925052923.GU7660@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__27_Sep_2013_12_01_07_+1000_Bpt5QyrZT9zDdR=2
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Steffen,

On Wed, 25 Sep 2013 07:29:23 +0200 Steffen Klassert <steffen.klassert@secun=
et.com> wrote:
>
> On Wed, Sep 25, 2013 at 09:59:19AM +1000, Stephen Rothwell wrote:
> >=20
> > On Tue, 24 Sep 2013 12:25:05 +0200 Steffen Klassert <steffen.klassert@s=
ecunet.com> wrote:
> > >
> > > On Tue, Sep 24, 2013 at 12:16:29PM +1000, Stephen Rothwell wrote:
> > > >=20
> > > > Today's linux-next merge of the ipsec-next tree got a conflict in
> > > > include/net/xfrm.h between commit d511337a1eda ("xfrm.h: Remove ext=
ern
> > > > from function prototypes") from the net-next tree and commit aba826=
958830
> > > > ("{ipv4,xfrm}: Introduce xfrm_tunnel_notifier for xfrm tunnel mode
> > > > callback") from the ipsec-next tree.
> > >=20
> > > Thanks for the information, I'll do a rebase of the ipsec-next
> > > tree tomorrow.
> >=20
> > Did you miss the end of the next paragraph:  "no action is required"?
> > Dave can fix this up (like I did) when he merges your tree into his.
>=20
> I applied this patch shortly before the merge window opened, it is a left
> over from the last develpoment cycle. I already rebased my tree onto
> net-next in the past if that happened, even if there were no merge
> conflicts. I did that just to see if everything still works. But I
> could also do a test merge to see if everything still works and ask
> to pull without a rebase then if this is the prefered way. Would make
> my life easier :)

That would be up to Dave ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__27_Sep_2013_12_01_07_+1000_Bpt5QyrZT9zDdR=2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBCAAGBQJSROboAAoJEMDTa8Ir7ZwVoRQQAIJQotoVoy91whcLvi1VEeTP
MKKLBQ+IKIF0s/qQHVEXmRindn4gjl7IDNLstpu+xXlRhXuBjzO/7HdfnsQk4KDx
VH0M9bfdY/NRT/XpjnPadqdItNw6f+KBt5dFndoEgVgMmmtcosjbeNT1I2bgdGZD
1hRMlPmN/GQjbXO8xW8WItsLHnwWccSsZDbNs6nZpxIdGAaFdL9sozIRpweHnEbr
BDjGdEunaVfL1kYdGA1hYWIEEhQgYAivJsGdHEHilRImvQuS1BYeyj8Fq2JQE7Cz
iMw3cx6IheynatCmH4ClczzTUuMnyGd/6iR2TQVJd7X8BMup12GNZD037RZZwrqh
K3/dwHSCU6nxk1ltHQ0jrzB7niSHmLq6j9susp5bNWbw6Qm96zOg+TCLhj6ajkbw
DOiCR24yqwr5DSa8DGnziDkjggBfKPOGC1CRzF0Mt3dedbx2VxqcReGxcALGB7O7
uJCDftBNiyFG21OBurFaud8FJ+dtpOBDdCFmrAkuVRmJxZdHhLXcNNtA1gpRy3mH
L78OKTUOfesoeLFjWAPjWs/1cVZOExEFgIfYmBIvv48sitnizjgOPbLqZuiJvofz
6EXQiKGcbMkfuft82tFHY5ubj5Gxj50uCbpu01iKYAFcNmOACXJdLP89INz+CER2
lMPUxFazuc65cccTG6YE
=SwBO
-----END PGP SIGNATURE-----

--Signature=_Fri__27_Sep_2013_12_01_07_+1000_Bpt5QyrZT9zDdR=2--
