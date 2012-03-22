From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: module_param: make bool parameters really bool (net &
 drivers/net)
Date: Thu, 22 Mar 2012 21:30:46 +0300
Message-ID: <20120322183046.GD3232@mwanda>
References: <20120322182623.GA29859@elgon.mountain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C+ts3FVlLX8+P6JN"
Cc: netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:45034 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226Ab2CVS2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 14:28:43 -0400
Content-Disposition: inline
In-Reply-To: <20120322182623.GA29859@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--C+ts3FVlLX8+P6JN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The same thing happens in net/ipv6/netfilter/ip6table_filter.c
as well.

regards,
dan carpenter


--C+ts3FVlLX8+P6JN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPa2/WAAoJEOnZkXI/YHqRdF8P/RwRdtk5NqzPfuqZFgxpunLW
3obf6FV4sN4xuY5FP1AA4YgFtJrT17NZDBgWhIosbVhIXb+YADoW+e76P80acv5r
tw39/gZ1URXkzBkmVnVJKH1ybXN904z7URYMzHqsF8z3ztWf7S3eFvnnMFxLJyPb
zyLZ7taPb+p+iQvqcU3hPZ/N0hoZUXebee0ocv5JnKLX39uEVoNq7Q4r4EhxsWtV
F5pkme+7U1aKsjWVFEZNYg5ttNok23uhNP5PxcAMwJgx0teYsj0Nttx2sIFmwLJp
Mq+NVjcQ8rDBcsqBtcssq39BnslEdcIVKtW0Y0zOsYFv+j8MdDKDBZaQt5uQrRMc
2XuTDa/K+tz+hZxD/SrlgTyUiDuA0EoDWfPOwvFL0TugAsKan9pTtvImiRsMp1RL
uTrRUe209y3kY9yuzF6FfE9HHTTSR2QN7qy2OULCTSEdr3Att44veF/Xj+3wNgU4
KuCKewuZbl9LHwk0IjGjHWLiJvMV8k3/JaWh0GLAypWufS1QOnNo2QtF+1XxLf1/
MpCP4yDE3OL2ThM/XFXDbhR9ss63s7k0go1raGMmIfzdq5hBNNIi9q7enRgUyzs9
+Ihpa6z18GAZFB/gBYCr8CvmGLfm+fjxyli/AFY0p6YnAqqVBjYALxaQ2gjzB8Lg
Ts5FDcpn3QA0SpXoNzWL
=uzaJ
-----END PGP SIGNATURE-----

--C+ts3FVlLX8+P6JN--
