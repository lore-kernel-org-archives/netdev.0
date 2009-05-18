From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH net-next] net: remove needless (now buggy) & from
 dev->dev_addr (part2)
Date: Mon, 18 May 2009 10:32:51 +1000
Message-ID: <20090518103251.86bd3f41.sfr@canb.auug.org.au>
References: <4A0A2059.8040607@cn.fujitsu.com>
	<20090513084011.GC3517@psychotron.englab.brq.redhat.com>
	<20090514103611.d8dc2bc6.sfr@canb.auug.org.au>
	<20090517.140004.153017718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__18_May_2009_10_32_51_+1000_6hI_XDNZHLgJdi3_"
Cc: jpirko@redhat.com, netdev@vger.kernel.org, sachinp@in.ibm.com,
	yjwei@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:33380 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753657AbZERAdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 20:33:17 -0400
In-Reply-To: <20090517.140004.153017718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__18_May_2009_10_32_51_+1000_6hI_XDNZHLgJdi3_
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Sun, 17 May 2009 14:00:04 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> I've put these fixes into net-next-2.6 and pushed them out to
> kernel.org, so you shouldn't need to carry them in your
> fixes tree any longer.

Yep, thanks.

Though if you had put them into net-current and sent them to Linus (as
preemptive fixes) there would have been no bisection hole in Linus'
tree.  Just a minor point.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__18_May_2009_10_32_51_+1000_6hI_XDNZHLgJdi3_
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoQrLMACgkQjjKRsyhoI8wYcACfVLrjMCcjMCx6Fu2ORt51rjVt
tOIAn1G3eKdXnhsdBln0zAXX4+AqunKU
=WPNb
-----END PGP SIGNATURE-----

--Signature=_Mon__18_May_2009_10_32_51_+1000_6hI_XDNZHLgJdi3_--
