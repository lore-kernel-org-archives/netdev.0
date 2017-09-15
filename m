From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: scheduling while atomic from vmci_transport_recv_stream_cb in
 3.16 kernels
Date: Fri, 15 Sep 2017 18:12:15 +0100
Message-ID: <1505495535.2825.41.camel@decadent.org.uk>
References: <20170912090852.qshtrioffwexkslw@dhcp22.suse.cz>
         <B8A42FAB-9E16-4943-98F3-86FC8F195069@vmware.com>
         <20170913151939.gf7n6rvvjtz47tz7@dhcp22.suse.cz>
         <AA27A6E6-2376-437A-9508-FD9C2427A465@vmware.com>
         <20170914085959.nkiefbzupwmknncy@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-G3V4guhry9E2rkRu0G0V"
Cc: Aditya Sarwade <asarwade@vmware.com>,
        Thomas Hellstrom <thellstrom@vmware.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Masik Petr <Petr.Masik@nudz.cz>,
        Sasha Levin <alexander.levin@verizon.com>,
        Stable tree <stable@vger.kernel.org>
To: Michal Hocko <mhocko@kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170914085959.nkiefbzupwmknncy@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-G3V4guhry9E2rkRu0G0V
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-09-14 at 10:59 +0200, Michal Hocko wrote:
> On Wed 13-09-17 18:58:13, Jorgen S. Hansen wrote:
> [...]
> > The patch series look good to me.
>=20
> Thanks for double checking. Ben, could you merge this to 3.16 stable
> branch, please?

I have a long list of requests to work through, but I will get to this
eventually.

Ben.

--=20
Ben Hutchings
Kids!  Bringing about Armageddon can be dangerous.  Do not attempt it in
your own home. - Terry Pratchett and Neil Gaiman, `Good Omens'


--=-G3V4guhry9E2rkRu0G0V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlm8Ce8ACgkQ57/I7JWG
EQl8Lg//VyOMEZQiuebFNXrIvH8Wud3XKrqcErCd1SrvRI3kozg7P0S/1Ng2xE4b
EKhcAlsW5efj8YKDpaUAcWcVYXL32LVdoiTJnmi2j0oHEBxa+HIZCd24x/fMqU9F
p5CVT9jDTyovFl4hZFT9zA/Und415jvOaNpEH4EN8TfarHXEG626ge4v/GdewJ1A
1l9Vi/mRGkfs14xnj+KvIadC8C72iGEFYPA6teAeZ1DcMt0krqEduHMme0MM00Yr
sj/o1ALvSwzgma/uctn6Z86tye/6b1nuDqCALSLRLceanMeRDCLos9gkNebs5qn5
9xIWoqlXkIOGiajRligiIhA/veb/IFVY7x7mdGgbrdlOu/xqJi8sJMEro8qi9p7v
Bwj3WK1wwnMnA2ZywvJ7Iei8M/y+G0+ulXvGpWNXlPgsV9BH7klMZas0x7dyqrL/
PMx7HohKL+CHHqgJUGVcN1IwF+nHizAjYH4a0oMsRauSfG8v28oTV/iY2vx66qVf
UCzfrl6xrpPPncEqL3UpmByYhl6y9mxp6hJzq2i6zwPEfHAIE+isAtVwaVIdRfb2
bUScDtxnwtni4OQ5i82o7y9g/Ce8bhXenmuOtVhdHNobb/bgn6r3vG5yJIIT1cjD
CaR4G8NbLp1vyx72U5MhzcuzwX5cRVn3jh9wDRlpUIHZYp09E20=
=DfCy
-----END PGP SIGNATURE-----

--=-G3V4guhry9E2rkRu0G0V--
