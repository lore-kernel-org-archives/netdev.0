From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH net-next] net: remove needless (now buggy) & from
 dev->dev_addr
Date: Wed, 13 May 2009 16:37:18 +1000
Message-ID: <20090513163718.b8eae43c.sfr@canb.auug.org.au>
References: <20090512093714.GD3399@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__13_May_2009_16_37_18_+1000_SUJ.7b0sgy8qshQM"
Cc: netdev@vger.kernel.org, davem@davemloft.net, sachinp@in.ibm.com,
	yjwei@cn.fujitsu.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:42312 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757532AbZEMGh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 02:37:27 -0400
In-Reply-To: <20090512093714.GD3399@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__13_May_2009_16_37_18_+1000_SUJ.7b0sgy8qshQM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

On Tue, 12 May 2009 11:37:15 +0200 Jiri Pirko <jpirko@redhat.com> wrote:
>
> Patch fixes issues with dev->dev_addr changing from array to pointer.
> Hopefully there are no others.

Since Dave is away, I have applied this to linux-next until Dave decides
what to do with it.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__13_May_2009_16_37_18_+1000_SUJ.7b0sgy8qshQM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoKap4ACgkQjjKRsyhoI8xRowCdFwAL4KVYOSGwk2zk15vUOK/O
JwsAoJMU4KEXvzJVIkSLOFH9xdQeFd4e
=yBwV
-----END PGP SIGNATURE-----

--Signature=_Wed__13_May_2009_16_37_18_+1000_SUJ.7b0sgy8qshQM--
