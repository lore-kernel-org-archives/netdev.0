From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 1/2] iptables: Merge libip6t_LOG and libipt_LOG into libxt_LOG
Date: Tue, 28 Feb 2012 17:06:05 +0100
Message-ID: <4F4CFB6D.4000403@nod.at>
References: <1328911856-19260-1-git-send-email-richard@nod.at> <1328911856-19260-2-git-send-email-richard@nod.at> <20120225133816.GA15864@1984>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig02FA765F188DF0053A95F999"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org, basti@b-bl.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120225133816.GA15864@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig02FA765F188DF0053A95F999
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 25.02.2012 14:38, schrieb Pablo Neira Ayuso:
> On Fri, Feb 10, 2012 at 11:10:51PM +0100, Richard Weinberger wrote:
>> libip6t_LOG and libipt_LOG share a lot of common code, merge them
>> to recude duplicate code.
>=20
> I have applied this to the net-next branch of iptables.
>=20
> See git.netfilter.org
>=20
> I'll merge it to master once linux kernel 3.3 is released.

Okay. What about the ring buffer feature?
Is there anything missing?

Thanks,
//richard



--------------enig02FA765F188DF0053A95F999
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPTPtuAAoJEN9758yqZn9eH4EH/140Y4gT/nM0K9OSRZoQXEPO
qwJipEcXcJPa0LVD2NxWntxSEwj9pgvpxZBQBAX4H4KvMmVkAiEEcg34HXrEt/5D
pkJA+A9nn1Sw3Fjit+L5WX+J0SVrki/GTbHcCg+4vY2r/nI8KVfw1xY+H/otx1dQ
i7NWNTDwzfjFdnQfwh6UdAZ9X23CMd6gmn4elUEYDlGJ5HuQ1Qe7lyAAm6WZt7qg
hN9qmeq8avzXKQRTfESAgPGDeqbERSy1IF7d5JqYS8sBdPfVseRF6TdyQcxwx4Ht
l0Pr2Mx3c3oLl0n3XjJiN+ElmgiCtyu7CnPXAsAShdU2s/gSu556FRSk46AEBLo=
=RL9t
-----END PGP SIGNATURE-----

--------------enig02FA765F188DF0053A95F999--
