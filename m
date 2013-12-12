From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Thu, 12 Dec 2013 10:04:15 +0100
Message-ID: <20131212090415.GQ3651@lukather>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org>
 <52A5A52C.50605@st.com>
 <CAGb2v67WiCaMpJEzA_X6o7uOu6i3w3FCEz7=N5HY0amQb01SZA@mail.gmail.com>
 <52A72C6D.60100@st.com>
 <CAGb2v64qQvqJSicA6MTAxeh1sGjWY=Pk=vDq=9J3pTQW+wkXrA@mail.gmail.com>
 <52A87A74.8040807@st.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tRcR9GoWqjXrt11v"
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: srinivas kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBP7YUWKQKGQEY73GKGI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52A87A74.8040807-qxv4g6HH51o@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--tRcR9GoWqjXrt11v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Dec 11, 2013 at 02:45:08PM +0000, srinivas kandagatla wrote:
> >>> 1. .tx_coe
> >>>    This is not exported in the DT bindings.
> >>>    Looking at stmmac code, not setting this seems to disable all
> >>>    checksum offloading.
> >>
> >> Why cant this go via DT as well?
> >=20
> > If you and Giuseppe are OK with this, why not?
> Am Ok with it.

Please note that I'm opposed to this until someone explain why putting
it in the DT is relevant (and not just convenient).

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--tRcR9GoWqjXrt11v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSqXwPAAoJEBx+YmzsjxAgG/kP/2S70fcVXrFmA91M3G7MI0bq
FXb1w7wojQiXDcHv4zvGmkpAI0MzmY3iSVbinAK+vv/ChC06hn5PUD5oQaQJHG1i
/uPADPCdgMjbv3aG2ig4/LsSoVe75nQ/EwY/KIgpJeWkRa1dZEVLsjcH4n8jCzVb
1qLqUTgSGtBiS+e+0JcsqfuHhH3tr7JIUCuJ6JuJs4WauKePnde0GvmANZ5o1uJe
6Dmb/Wgqbi2qh0hryAd26+XSmonz5aVPGFZ3Iw1OaoDQNUaW/y5nD+GGbR8Qsq7V
puEndZu4+0RyjL96GpYDT8sSc/KoVbKMVZXvwYDk6U1/DSNz2D0ASkqjVGgMTIzs
C0n1id13BZAD2FtUghLga2Zv2gm8GQ7N/IcDf5OYrO2+AgT7V07C/PurxZzBJBPt
SaumoPhUD+avRM1Iw1XVg8DlNB/bcbWQm4YpVQ/pe98LmxkPAkIqrxzWDQQ0P9EE
4HjHcdBo5QJNGjgXtQ/Xo23niO1XEKOb17PcSqndf6PRS/VUR23P8i/RxAzV280K
+lcpTXumIhOTGvjIpCTABjOxAehqdpd5FWWMYve5IMZakbpEHw79DV6R3VvDdHY9
o7kb4Mwk1kxHOKFAk5aXElYQH4tYxv80hjOeeO5gCBlE/++StCuS/kHTSMjEKA1Y
WzVCmVv92XJbpMKFk2xg
=yDB+
-----END PGP SIGNATURE-----

--tRcR9GoWqjXrt11v--
