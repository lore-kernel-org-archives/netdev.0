From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v3 0/2] ASoC: atmel_ssc_dai: add option to
	choose clock
Date: Wed, 12 Feb 2014 17:23:42 +0000
Message-ID: <20140212172342.GI28112@sirena.org.uk>
References: <1392012586-30790-1-git-send-email-voice.shen@atmel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2586537175153997943=="
Cc: Mark Rutland <mark.rutland@arm.com>, alsa-devel@alsa-project.org,
 Stephen Warren <swarren@wwwdotorg.org>, linux-doc@vger.kernel.org,
 Takashi Iwai <tiwai@suse.de>, nicolas.ferre@atmel.com,
 Liam Girdwood <lgirdwood@gmail.com>, Chas Williams <chas@cmf.nrl.navy.mil>,
 Lars-Peter Clausen <lars@metafoo.de>, Arnd Bergmann <arnd@arndb.de>,
 linux-atm-general@lists.sourceforge.net, plagnioj@jcrosoft.com,
 devicetree@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>, linux-sound@vger.kernel.org,
 Rob Herring <rob.herring@calxeda.com>, linux-arm-kernel@lists.infradead.org,
 Richard Genoud <richard.genoud@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
 Rob Landley <rob@landley.net>, netdev@vger.kernel.org
To: Bo Shen <voice.shen@atmel.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <1392012586-30790-1-git-send-email-voice.shen@atmel.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org


--===============2586537175153997943==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+NAfxSaP7cKOSWOx"
Content-Disposition: inline


--+NAfxSaP7cKOSWOx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 10, 2014 at 02:09:44PM +0800, Bo Shen wrote:
> When SSC work in slave mode, the clock can come from TK pin and also
> can come from RK pin, this is hardware design decided. So, make it
> available to choose where the clock from.

Applied, thanks.

--+NAfxSaP7cKOSWOx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJS+64aAAoJELSic+t+oim9HdEP/1s3b2zCDKiZwxz8pMZEXXZL
PLWDH6glrCLjH0UBXgXvlC2wVgjNlX8EK8HCBWTYBYKEEM0d1TrPojWFG+SMptDV
41WSQhbPOA7zsuP8dWqk6DwGTgTKgfgSd9G6UZQ8EQ9C87xwvpeuCj0QQNsYYHt8
7YhksW+zOl5qXuW1Vcf3UX7JFgQ/ihQOPAp+g5CBjM0BkX2a9bH44qWtWNnS9FJo
vt4GWngybTU/NSB/PQ+bF0abpnGuu2qKjQjc73GBgtCtxkn6NNyQuqi0hPF/PiDP
2ShBveB6k9UOrYw1qyxzh/ojXNRpBYyRAO1uEKU9dfBFVhri9I0sVGR447h69NEy
068FPY7kjNYpasyK8OF9lUQzk8llZvenapVhjgaSCV7oqygix4p4S+TetsOJ+/3m
MuY8Y8XGipyXxRTCI4aGynZp2I4XsQRCXQJWFjZdJWU6i1/2UZQ/YJIuyU1NcyhK
vAD0qyigXsGaYLyGgyB4wQcG2q8ugL+DnqYygc2/QWPtu2fG4m2P5ca/tKXomBET
ItcQoVKGOOBpuXY2IG+nRs991r9rDVsiMBYRxd1t9lX7gbTITigIln3JuW9Y8eQx
Qpb/PnzvP7YSzSgkd2bKFMv9jxffekTlhG+PYATVlYY2gaps/5JnuHh3FwR/kRUq
vCUR3GvJPsUlOPJRVskW
=H++v
-----END PGP SIGNATURE-----

--+NAfxSaP7cKOSWOx--

--===============2586537175153997943==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2586537175153997943==--
