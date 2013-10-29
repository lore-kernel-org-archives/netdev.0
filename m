From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 09:04:49 -0700
Message-ID: <20131029160449.GD16686@sirena.org.uk>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
 <20131029060427.GF11580@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0643476374379051913=="
Cc: linux-fbdev@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>,
 Linus Walleij <linus.walleij@linaro.org>,
 Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>,
 Thierry Reding <thierry.reding@gmail.com>, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org,
 Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
 Vinod Koul <vinod.koul@intel.com>, Joerg Roedel <joro@8bytes.org>,
 linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
 Eduardo Valentin <eduardo.valentin@ti.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, linux-serial@vger.kernel.org,
 linux-input@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>,
 Chris Ball <cjb@laptop.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-media@vger.kernel.org, linux-pwm@vger.kernel.org,
 Samuel Ortiz <samuel@sortiz.org>, linux-pm@vger.kernel.org,
 Ian Molton <ian@mnementh.co.uk>, linux-arm-ker
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20131029060427.GF11580@verge.net.au>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============0643476374379051913==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2iBwrppp/7QCDedR"
Content-Disposition: inline


--2iBwrppp/7QCDedR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 29, 2013 at 03:04:27PM +0900, Simon Horman wrote:

> I think this is a step in a good direction.
> However, I think it would be even better if the architecture dependency was
> removed completely.

Yes, please.

--2iBwrppp/7QCDedR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSb9yZAAoJELSic+t+oim9bYwP/iUUXI14zyW5LzIhwP6LBlEr
FOYrZVwQxqUbnA4hDctQCmrA9VikBRNUmlDoUx+xxNNRLd7Zelm2iC8xQh4U1JJX
9pJ/yv1FHi4EBNmWRK7gL9RXEUM7U4Jt1/nPgW64Kw7ooMwsKmMssrDmwm8xorRD
iFvd4kY6ZiYz1m5Qvn1rQM05qskN1xGR0jdaxhH8DMCkhA0UyGhLoeFWXDy68T1A
fsJQrF5mRjO/DNqgI/DqetC8gGy1gjyqETra6Ah730luxYN8bZxbmmbjBc4pYDtY
7pjRnqVjPMCG+seGgAzlCkgk8t56mHfkrzSRnF0IZ4q5PW4uY1QpzuEs2vB3SI/A
bS3SD8i71t88jsQ0G/skXAbme0Rl2J+7al3DDMJpUf8yCbFQTZoeFSbe75PgA5Dl
C6D/7nuK8BIQw5/SV+iCVFN99nKXvJZHFc8wdB7YbXnSQCUdmCLnbkkjYS7HxkQ/
4OB+XjOgVcGeDCjJrL38LrarJIu588qHe6Cz+8wlJvmV/B9pRWwsXNz2OzU8gSPp
9RKDNPrpaF+aEoYONBJkHIJf8nqBKipk4xFOmOVxEoMA8oGCAAKltM/ktJdgdfir
Kb+MgiqubYkjFUFJ08WBqs+L63H4mHQ3JcYAw9NsAiKf1XKJuwdIwddhPlrgTvrQ
HY0P0bFfzdsgfQfvQ5gC
=3XLW
-----END PGP SIGNATURE-----

--2iBwrppp/7QCDedR--


--===============0643476374379051913==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============0643476374379051913==--
