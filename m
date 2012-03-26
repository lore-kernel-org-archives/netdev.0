From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH linux-next] dmaengine: add context parameter fixups
Date: Mon, 26 Mar 2012 11:33:55 +0100
Message-ID: <20120326103354.GD3098@opensource.wolfsonmicro.com>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
 <CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
 <1332740082.19804.15.camel@vkoul-udesk3>
 <20120326094200.GA3098@opensource.wolfsonmicro.com>
 <1332755670.19804.91.camel@vkoul-udesk3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="q9KOos5vDmpwPx9o"
Cc: Fabio Estevam <festevam@gmail.com>,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	paul.gortmaker@windriver.com, dan.j.williams@intel.com,
	samuel@sortiz.org, lrg@ti.com, perex@perex.cz, tiwai@suse.de,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, fabio.estevam@freescale.com,
	alsa-devel@alsa-project.org
To: Vinod Koul <vinod.koul@linux.intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1332755670.19804.91.camel@vkoul-udesk3>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--q9KOos5vDmpwPx9o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 26, 2012 at 03:24:30PM +0530, Vinod Koul wrote:

> Now either I drop these from 3.4 or merge Linus's tree and apply
> Alexandre's fix (as that is the right fix rather than one in asoc tree)
> And since this was required for RIO patches which are still WIP, I think
> I am leaning towards former.

Gah, WTF is going on here?  Has this API change not been sent to Linus
already, and what is wrong with the changes which Fabio sent?  I've
already applied Fabio's change on the understanding that this API change
done and dusted.

It seems better to do a minimal fix at this point rather than churning
things again...

--q9KOos5vDmpwPx9o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPcEYBAAoJEBus8iNuMP3dvIEQAIGpSA1r/3J24HpN5VCXzmV0
akMfoEPivJrcVMhp7tBTQukXoPan8HCvoFkvEDcqO6dkuwQoPxCE6ADYs/5WGwS0
LQ9oeUNo+hMq/bZhODewkfifzzcwIfz3AenP43QJw4i9VDrD5iaXGil6IO/2iM+G
/moGmblgyZ4Cax7jxf+/uddrEm5+05hF1KgDhvK14iw1iz8cGC4rKHXtAuynO7Ok
O6Aok+uj9QpyS45NwdSE/3iMgXR2D0t4Z1PMPhMe3fn3txQV9jXkpt0EV0sQ8j4j
N6Uy48ILDwgWFA7d6aWgJ2ELdfHlrcmiYG1/m85sAi5fe/xdzUzezyHHKcCwDFPr
TNmgoJWbYAx/jFqstIAUGYpXoz+6jvYIrOXWXGIBeGaETNM3Ryed5q20G0WOa6cA
QmOyR3pNTbw8k/T2amgO25emTFKlTZfbcGcAB26VHFrYg39n6N4EitzqWca/tUjQ
WupjaGw984q9IlNp/4lpZjbeS7vLM50YbBVcC0aP32XBnAMxswUZLaQEQImVgPiY
yKabsoCFoYOuo6h8GtI/x5N39HJAchMQMSSZO6y7NmIbpcES2xq/Q7LUZMzOierH
b2/V/b3rsm/Vp8Lj5vluxgT3Y6Tm/s4Lwa2P55qYLFzORqDsOWtOc9dospClipgF
P3TB4R/mS/jsw2n+xQT+
=Y5TF
-----END PGP SIGNATURE-----

--q9KOos5vDmpwPx9o--
