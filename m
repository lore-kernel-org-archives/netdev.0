From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH net-next v2 4/5] net: add netlink_ext_ack argument to
 rtnl_link_ops.slave_changelink
Date: Mon, 26 Jun 2017 10:43:02 +0200
Message-ID: <15d2138d-5026-a35b-8a3c-2a88d05df688@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
 <498ff06f59d5ce13b2ad3e1c1902c3d348ca3c00.1498425679.git.mschiffer@universe-factory.net>
 <b097a69e-4449-b124-c39e-4dbdbae7c218@gmail.com>
 <dd3f596b-4519-398c-a2ec-afdaf5f2f058@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="JC0oJgSI9Wnk4iEUAqArTO5Itvw8Jcvr7"
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        linux-ppp@vger.kernel.org, linux-wpan@vger.kernel.org
To: David Ahern <dsahern@gmail.com>, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        wg@grandegger.com, mkl@pengutronix.de, pablo@netfilter.org,
        laforge@gnumonks.org, paulus@samba.org, jiri@resnulli.us,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, stephen@networkplumber.org,
        arvid.brodin@alten.se, alex.aring@gmail.com,
        stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        johannes@sipsolutions.net
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <dd3f596b-4519-398c-a2ec-afdaf5f2f058@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JC0oJgSI9Wnk4iEUAqArTO5Itvw8Jcvr7
Content-Type: multipart/mixed; boundary="M9wPtn9LNmglMliK9geWLfqWoV221Jv7U";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer@universe-factory.net>
To: David Ahern <dsahern@gmail.com>, dledford@redhat.com,
 sean.hefty@intel.com, hal.rosenstock@gmail.com, j.vosburgh@gmail.com,
 vfalico@gmail.com, andy@greyhouse.net, wg@grandegger.com,
 mkl@pengutronix.de, pablo@netfilter.org, laforge@gnumonks.org,
 paulus@samba.org, jiri@resnulli.us, dsa@cumulusnetworks.com,
 shm@cumulusnetworks.com, davem@davemloft.net, stephen@networkplumber.org,
 arvid.brodin@alten.se, alex.aring@gmail.com, stefan@osg.samsung.com,
 kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
 kaber@trash.net, steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
 johannes@sipsolutions.net
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, linux-can@vger.kernel.org,
 linux-ppp@vger.kernel.org, linux-wpan@vger.kernel.org
Message-ID: <15d2138d-5026-a35b-8a3c-2a88d05df688@universe-factory.net>
Subject: Re: [PATCH net-next v2 4/5] net: add netlink_ext_ack argument to
 rtnl_link_ops.slave_changelink
References: <cover.1498425679.git.mschiffer@universe-factory.net>
 <498ff06f59d5ce13b2ad3e1c1902c3d348ca3c00.1498425679.git.mschiffer@universe-factory.net>
 <b097a69e-4449-b124-c39e-4dbdbae7c218@gmail.com>
 <dd3f596b-4519-398c-a2ec-afdaf5f2f058@gmail.com>
In-Reply-To: <dd3f596b-4519-398c-a2ec-afdaf5f2f058@gmail.com>

--M9wPtn9LNmglMliK9geWLfqWoV221Jv7U
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 06/26/2017 06:08 AM, David Ahern wrote:
> On 6/25/17 10:04 PM, David Ahern wrote:
>> On 6/25/17 3:56 PM, Matthias Schiffer wrote:
>>> Add support for extended error reporting.
>>>
>>> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
>>> ---
>>
>>
>> Acked-by: David Ahern <dsahern@gmail.com>
>>
>=20
> Actually, you are missing the chagne to br_port_slave_changelink.
>=20

I'm confused. I am changing br_port_slave_changelink? All my patches are
compile-tested.


--M9wPtn9LNmglMliK9geWLfqWoV221Jv7U--

--JC0oJgSI9Wnk4iEUAqArTO5Itvw8Jcvr7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEZmTnvaa2aYgexS51Fu8/ZMsgHZwFAllQyRYACgkQFu8/ZMsg
HZyJhRAAjAUpXCVHRPBm77DhHRyvY55WBNzSjQKFJGE5HDSkBBsTdYz7HqgSpjyh
bbkmD/8zzV0gysZR4v2u8WNTOxu7+uFInXT5p7MnXUcNYnBhFNMrgrt43gQjfqUa
JDq6Lzr7pWDDCMBIAY6TFT6pqZ/oSnYid6zuklol9DcJO4bQq7kfuzJzlGRgdlaH
OoMOq6thQjeliFSXCU4ac/3K1vSi5O2dtV7F1mY+sWW3c82HOwPTx8GUCNMZ0mj+
ezqZjEJ96Qxqw4i+TLQe4YBKNSn7zfXzLczv9qDtPHcvtAkK1U1rRv4HcGTmJEYM
igqcWPFW/RaNH2Dqu7acZeQCF4vV5rvFZdBuxAguK18262W5UUo4M1EH/BdaNKq6
kD+GSOac9uxCXImWF9va/94kfceFXzI66m72BZWUXZyIEGwzMtdTu2JCryVOeEhg
LIZ4Ajdv46rY2r/jexxyNLg9dypC+T481/zJ8Df2qkcf8+Cr4QpeaFx9pc5FEeHT
2qiGmnuMFZCSqJfxLqzBdnoodkiQ1POWG6kGQOCH4XtyLJFwe57XEjA6FpB3p9ZJ
ptyDNUnZWG2cu3Xhlec+9ftnwhkWAW+8Q0J8n6ebMVzprLRVFF3r9ZlVK6ISryA4
rb+K2cafSIyRSmgGaXaTUfpZRyKj0ixkdvGL35pHda9jY943rx0=
=VFO7
-----END PGP SIGNATURE-----

--JC0oJgSI9Wnk4iEUAqArTO5Itvw8Jcvr7--
