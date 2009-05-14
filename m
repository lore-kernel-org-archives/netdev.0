From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH net-next] net: remove needless (now buggy) & from
 dev->dev_addr (part2)
Date: Thu, 14 May 2009 10:36:11 +1000
Message-ID: <20090514103611.d8dc2bc6.sfr@canb.auug.org.au>
References: <20090512093714.GD3399@psychotron.englab.brq.redhat.com>
	<4A0A2059.8040607@cn.fujitsu.com>
	<20090513084011.GC3517@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__14_May_2009_10_36_11_+1000_G3S2TuPgwuWTFN+9"
Cc: netdev@vger.kernel.org, davem@davemloft.net, sachinp@in.ibm.com,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:59063 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455AbZENAg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 20:36:28 -0400
In-Reply-To: <20090513084011.GC3517@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__14_May_2009_10_36_11_+1000_G3S2TuPgwuWTFN+9
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

On Wed, 13 May 2009 10:40:12 +0200 Jiri Pirko <jpirko@redhat.com> wrote:
>
> Missed part of "&" removal.

Also added to linux-next until Dave has time.

All three are now in my "fixes" tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__14_May_2009_10_36_11_+1000_G3S2TuPgwuWTFN+9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoLZ3sACgkQjjKRsyhoI8ymwACgqB1kz9ZXDEJClLELT5gp2FKF
3QYAoLMMrfvERmMaRax3fUE8qSN0aBX/
=kqt2
-----END PGP SIGNATURE-----

--Signature=_Thu__14_May_2009_10_36_11_+1000_G3S2TuPgwuWTFN+9--
