From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/3] netfilter: Fix copy_to_user too small size parametre.
Date: Thu, 1 Mar 2012 14:31:15 +0300
Message-ID: <20120301113115.GD22598@mwanda>
References: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n2Pv11Ogg/Ox8ay5"
Cc: bart.de.schuymer@pandora.be, pablo@netfilter.org, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--n2Pv11Ogg/Ox8ay5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Actually we had this discussion before.
http://www.spinics.net/lists/netfilter-devel/msg13860.html

Here was how we ended the discussion:
http://www.spinics.net/lists/netfilter-devel/msg14083.html

I was supposed to send a patch, but I lost track.  Sorry about that.
Perhaps you can send it?

regards,
dan carpenter


--n2Pv11Ogg/Ox8ay5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPT14CAAoJEOnZkXI/YHqR4WEQAKyYMKxPwFaoyYA//V0R/jRc
FgEpF62FbKuMv/nGYQgqurCqpQEVCQGLrGYz+7sc+hgPs7fl96yHkGDC5vLk23Vr
zlPhNRg1z2s+alLQOmTUt7SmSlQfx9irHwWpBv2KTEFJfU4BRXIE+xjox2NHDaE0
m//IvLCQ+jyT0PrXqWrY+c8FXE6xYfD8m0sfE9lBuY5gCVWjFW5uLCV9TFuM1RsX
EwNro+zQeWmdWaqFUBjg83WHfp3Vw/xwmTJbwk9Ud4B1xkhTbndIowmDM2h/xoZF
LjhU65ULu8vylKHTq+S005TvOaC2WvTMjeN9DT4fNYRriMR7sim7/sLSjn59pmEP
xkJSt3SDiwX8YYv20gc1W5L1U5Z9CL6PacIg55KdWiL66Z/57pf/4uGkfVq3H1Qr
w9kYWNJp29TlSkhYOPrZSX+o8ANmXgfPL8/9IDB1KvZg6HVxiWzi6Nvdf3oTobMr
CyeRAoVyx4pTeoGFP/FSezB7nAWI2uI+8jtE+EYuA3GUi+OG6MDY+AGuBedCreKh
qWnIcW4ozK/CDb45V8J/u1XOn7uSKjrTrKqHYD/LVrragG9/SCjO7mfHQM7FrCvO
PAel8swOsIIMj/v2bX5DD+KuAilPfRhpkn+wfGRILHKLLvTEpeysP3uzhuB0t0MJ
wv5D9iS5ndtNo1U7A7O1
=YjLW
-----END PGP SIGNATURE-----

--n2Pv11Ogg/Ox8ay5--
