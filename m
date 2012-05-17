From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 3/4] e1000: look in the page and not in skb->data for
 the last byte
Date: Thu, 17 May 2012 05:02:33 -0700
Message-ID: <1337256153.2714.52.camel@jtkirshe-mobl>
References: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
	  <1337254070-32500-4-git-send-email-jeffrey.t.kirsher@intel.com>
	  <4FB4E34F.2050004@linutronix.de> <1337255417.2714.49.camel@jtkirshe-mobl>
	 <4FB4E782.3070502@linutronix.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+38HMKZ/aL7M3h+Ah4iM"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13889 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510Ab2EQMCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 08:02:34 -0400
In-Reply-To: <4FB4E782.3070502@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+38HMKZ/aL7M3h+Ah4iM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-05-17 at 13:56 +0200, Sebastian Andrzej Siewior wrote:
> On 05/17/2012 01:50 PM, Jeff Kirsher wrote:
> >
> > Your correct, I apologize.  This was my fault, I applied your v1 of the
> > patch and then realized there was a v2.
> >
> > I will re-send the series with the correct patch.
>=20
> Okay. I haven't seen [0] in the series. Did you merge it somewhere?
>=20
> [0] http://thread.gmane.org/gmane.linux.drivers.e1000.devel/10019
>=20
> Sebastian

No, not yet.  Aaron is still validating that patch since it was actually
the last one you sent me.  I expect to be pushing it in the next day or
so with some ixgbe patches, once it finishes validation.

--=-+38HMKZ/aL7M3h+Ah4iM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPtOjZAAoJEOVv75VaS+3OpvIP/RkxpmX+eNnoOhWBOC+/F8Jh
OuSl/Fv0fe6JqFwpaJc06+dSVDQv8C3jkwKxUmmnO0ljWJFZgBkNHUnvkmtKLkr0
yzMAI6v2DTGeKcPrwQTBkM0NUuNHRAVIBF+fo7ZWQRzc+MzFvBipXiKqf/3ZFX0D
lCMchba66m8N09C/ht45+Pe4EoSXpRPaFobkOGA44Punr9OJFmXn1HR9lPopZi/O
HLNqnTQTByJH6AzYYcuD4D0iglAOqF5utGsI13ybTwavodKkFuBqOQ0U5mLFGMKu
8hJWQM0zV8Oc5UVS2RXIo4KYxSUvKE1n7boxC/1t0pqy7BPLiG0IWremWdshqby6
8t8EMZo0OOZMFjVKmPavbtERsuKodDcwSJyIlkIl8zo128aOwqn5zPBveyHdyW31
c1Ay1+v3d5kYNTxoN3BNIR6mrUcMdpJQK6WLlsRdN2RG6iCm9hJDQonIYZfRP9QM
eQN5iFeYHAXNT/2QE54oR7WagqomN1NhELBlCMFVHBDyuvbk52c/q2enqRIFewCE
oRzFh+eD38hF3WCdPvccTVK1TUkA7QSR1m/G5dtfCkG6p/QxRJXm+91omiXmQpbD
5nGN6RFNnO/9Mbk6n/FkF4tCQ5NwDZlgbGn4qkDpqRctInW7KSoZSt5J1lF4RYa3
tMrPJpYTi17bO27HgFoZ
=Fk2T
-----END PGP SIGNATURE-----

--=-+38HMKZ/aL7M3h+Ah4iM--
