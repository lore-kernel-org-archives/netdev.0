From: Thierry Reding <treding@nvidia.com>
Subject: Re: [PATCH 2/4] net: stmmac: adding multiple buffers for rx
Date: Tue, 4 Apr 2017 21:15:39 +0200
Message-ID: <20170404191538.GC24271@ulmo.ba.sec>
References: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
 <4f35e9a73521ba4ab4868c75950166fb757b5f8a.1491328304.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="FsscpQKzF/jJk6ya"
Cc: <davem@davemloft.net>, <clabbe.montjoie@gmail.com>,
        <niklas.cassel@axis.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate16.nvidia.com ([216.228.121.65]:7895 "EHLO
        hqemgate16.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755231AbdDDTPq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 15:15:46 -0400
In-Reply-To: <4f35e9a73521ba4ab4868c75950166fb757b5f8a.1491328304.git.jpinto@synopsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--FsscpQKzF/jJk6ya
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

One more nit: subject should say "... for RX" for consistency with patch
3/4.

Thierry

--FsscpQKzF/jJk6ya
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljj8NoACgkQ3SOs138+
s6EKFQ/+N5uIJuNTPyqFuNyblj/MYnpg7vra8x/aJo0mIV//i/+EcUOhcufiD3pv
nL8xY5kQ/dvf3kPzhaYoLkdFm2GH4fA32dz2uArZReGdta+pnx0/nmYnhrvgjBiG
VB5RwQx13a9T84LNlNXrQNUxLJcTc4SmgZ8JCM6VeL1fctY7mrcLInTkmfae87je
87w6rP3NU57XFcNG+OiQ+GaSNZ9KzWY6pD3nko71kb9O+kJA669FE3iD552WUxIJ
O/uaVeyb/Xk77Xat63uR2wrsjwam2Wyur5JkaYwaP1G/xTyzKN4fevZj2N+bby52
Zsz18jGZ8Q4Ke37XUZLAFstD3F+XCNCdFmO8x8jz0LsNntZBUK79CgXF2uIgWkzB
YTGpZ6tpQ0lN033P76MgWDjzg31RZpATFsvWxBFuP4AdBFuS7rhxIAhA3COqlDTv
S/zGprQ+/TnPJOIgwoLAsABX5dmcTaJcq9n0kofV9n12aeSlKiVeOTh4m1J5igD7
j05x3B8pCB1tc2eC5J9rAF4s2m2L3jltHDw/ydP0DTNhF4QVPfkHEs59E4QHDRM0
hz0kGq/kTdI5bm4IGRentzX54GExVf9PiDBMiwlDgGgL5d98xDsTe9zOHYeP1SM3
hTLrOQbIWorzHiMAOUDAeLomANDtRPUMzq1JhYu+nnV/tol7HaM=
=8VNz
-----END PGP SIGNATURE-----

--FsscpQKzF/jJk6ya--
