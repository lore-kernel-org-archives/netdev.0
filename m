From: "maxime.ripard" <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 02/10] net: stmmac: Honor DT parameter to
 force DMA store and forward mode
Date: Sat, 7 Dec 2013 11:07:37 +0100
Message-ID: <20131207100737.GI24519@lukather>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-3-git-send-email-wens@csie.org>
 <20131206.162606.2277176361893801778.davem@davemloft.net>
 <CAGb2v67ZNtbQm+ZW5v_3wNbz1=oLhXks6gbTSjLYa=Nnoz8w-A@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nEsDIrWrg+hrB7l1"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"rob.herring" <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Srinivas KANDAGATLA <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBA7IROKQKGQEZLTJSQI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v67ZNtbQm+ZW5v_3wNbz1=oLhXks6gbTSjLYa=Nnoz8w-A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--nEsDIrWrg+hrB7l1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 07, 2013 at 09:23:27AM +0800, Chen-Yu Tsai wrote:
> Point taken. The current implementation will override settings passed from
> platform data. ORing the two would be better.

Platform_data and DT-based configuration are pretty unlikely to be
used together, so ORing it doesn't have much sense.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--nEsDIrWrg+hrB7l1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSovNpAAoJEBx+YmzsjxAgVS0P/AyW/lt3PWZIfXjd0qY32uvA
jj3QPwucvqo0KzQQezdUWX65TXHGLwpWTkduTsFw8pHqUz3YTpiY9KD9GrrSMICn
WB/Xd4AWcNTimFdLsoIHv8dcLUuK0iPNKyxjd5g+IxV+Py5dRkpXy1KTV+yL6T+8
D1AQY1gL9efBgYEiiOrPAILVKe2QfXr9PTsdV9gcMDFPbsfAW+XBGZBgYsmA98GP
Y0EshDP1XClbP4JY+PRzRAXoggPTK2bIDkVelObU8+75w8LOlPbiUu80W/Ji63vH
R+EzeZ+gjhwdEMP2utdDgFWuZUWIC7F4es3OIaSBRwInWcAuokd3BeqlH2JB556J
7jIdU8CSRbttr7I+mAzAmIPC8GYwc6aEvNTrR0yPge4ZmF4tz7bjNRpwk1mLDtxv
xOJ4u2TtnCjb8LRkIoLblTfb62MBz49vAy/ZOtoCbtUP169c5ltthX7c6WDYexk+
t/rLW5X9NO+DJ88TU8OP+75HqkrEi/5PLZyr0+aobTWaQLuDuMrIlq40Zl7wnL2A
kG3nFDdqNtnoeoCLxohRNb8ofHNcG9ozysZtUgYKNm9oF6HIyWXs9pZuJ9Hi0+RK
qJ0ZlVgDFPw31OzMSE8FuJ/ibFvU79pe56UuFnEDPKVX6dnBAI2B64K7EESrKxMp
xcdYffxuMaVhA4EbMHTB
=6Wxl
-----END PGP SIGNATURE-----

--nEsDIrWrg+hrB7l1--
