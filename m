From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Sat, 19 Mar 2016 11:27:25 +0100
Message-ID: <56ED298D.4020100@imap.cc>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <87lh5udbcv.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1484029732722887663=="
Cc: devel@driverdev.osuosl.org, isdn@linux-pingi.de, linux-doc@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Holger Schurig <holgerschurig@gmail.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87lh5udbcv.fsf@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============1484029732722887663==
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="K8rjar1FO5fiqSQTBUN7CHNdsTk8iUKv2"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--K8rjar1FO5fiqSQTBUN7CHNdsTk8iUKv2
Content-Type: multipart/mixed; boundary="3861iW5jqANmv9F5FSXCDA68tPiPDhbfS"
From: Tilman Schmidt <tilman@imap.cc>
To: Holger Schurig <holgerschurig@gmail.com>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, devel@driverdev.osuosl.org,
 isdn@linux-pingi.de, Jonathan Corbet <corbet@lwn.net>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-doc@vger.kernel.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>
Message-ID: <56ED298D.4020100@imap.cc>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <87lh5udbcv.fsf@gmail.com>
In-Reply-To: <87lh5udbcv.fsf@gmail.com>

--3861iW5jqANmv9F5FSXCDA68tPiPDhbfS
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

Am 07.03.2016 um 07:57 schrieb Holger Schurig:
> I know that in Germany a good amount of land-line telephone line are
> still using ISDN. [...]
> Especially company line are using ISDN still, and there are some Linux
> programs that act on then, e.g. Asterisk and derived PBX software has
> ISDN support which is actively used.

AFAIK none of these uses I4L anymore. Asterisk dropped I4L support with
version 2 if my memory is correct and nowadays uses CAPI, mISDN or its
own DAHDI interface.

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=E9ger.


--3861iW5jqANmv9F5FSXCDA68tPiPDhbfS--

--K8rjar1FO5fiqSQTBUN7CHNdsTk8iUKv2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJW7SmWAAoJEFPuqx0v+F+qRtEIAKMN2ufDtGcC/GzQ1yI6Vmcl
PpG7RtBfTBKxZKgPN4f1Jb6L+OsFhL+5m5UdDqzoSaszGYLmSm8qA0AFuJg2WGa+
bqrIP5R8NGU7Gn936ZF3eNQCU3uJkWfPqB4t/GEF07BrQCmnAjMsVSReKSy2wjwQ
W23IIHstmj5WekyOv438zC42H2rYp1yNLFCIYqt3nnw74WiIs20R2BiNQ+EPztft
wo6qJUQc5M7L0f4Vf7aPzr2Nd2aRXnBokirw09Cyy5Tpl8OLdFu57BJj9wcBGyF+
xuebNdmT3tr+3DzIgdExsQnPJI5rS6rGYj1yaEDUkP9LIl5DYqPDb0i5TrYj61Y=
=xPva
-----END PGP SIGNATURE-----

--K8rjar1FO5fiqSQTBUN7CHNdsTk8iUKv2--

--===============1484029732722887663==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============1484029732722887663==--
