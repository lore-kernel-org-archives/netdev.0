From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH linux-next] dmaengine: add context
	parameter fixups
Date: Wed, 28 Mar 2012 16:51:06 +0100
Message-ID: <20120328155106.GY3232@opensource.wolfsonmicro.com>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
	<CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
	<1332740082.19804.15.camel@vkoul-udesk3>
	<20120326094200.GA3098@opensource.wolfsonmicro.com>
	<s5hwr64wx0p.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0057334213141686048=="
Cc: fabio.estevam@freescale.com, Vinod Koul <vinod.koul@linux.intel.com>,
	samuel@sortiz.org, alsa-devel@alsa-project.org,
	paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	linux-next@vger.kernel.org, dan.j.williams@intel.com,
	Fabio Estevam <festevam@gmail.com>, lrg@ti.com
To: Takashi Iwai <tiwai@suse.de>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <s5hwr64wx0p.wl%tiwai@suse.de>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org


--===============0057334213141686048==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="t4k3FX2BKM3OLyzG"
Content-Disposition: inline


--t4k3FX2BKM3OLyzG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Mar 28, 2012 at 05:44:22PM +0200, Takashi Iwai wrote:
> Mark Brown wrote:

> > No, not yet - it was only sent after the merge window.  Quite why nobody
> > managed to notice it before then I don't know.  It'll go to him soon, or
> > at least to Takashi, but don't know if it'll make -rc1 or not.

> How is the situation now?

> FYI, I'm going to send a pull request to Linus tomorrow or on Friday.
> If anything needed to be merged in rc1, it must be there in time.

It's in my tree, I didn't see an enormous rush to get it in TBH.

--t4k3FX2BKM3OLyzG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPczNCAAoJEBus8iNuMP3dq1kP/2fx+sTM6QZ1T8IcQRd+8HtY
c5GajFfOH+nOH2IPD2pd4Bn0Z4povKjxq6Lss6AaHS9ePs2JCYLCwR7+5InBHelr
eu3hrkSFnXnGmlQrhi84FN0zgpn0+Sbu70W0gLCAIzbmubMLpQR8J2ZRrh2pYZgl
Ou2K+Gmt0On5bijnwiOlpWGN5Vie0VmA9eTjuSay5Ohb58Rg/suxrRztmTeuX8aU
9D5AOxAbwag/5CKB2xbmln2lupHn/EyNqTM9FKrSnsHvR2NYIw61ZxAF/izCDakD
CMIMQNsV7tGShjmI9tG2XCJw/39xw0wcUf7D22Bq09lObiEf+NOHJ4ex+91tKwP5
xx69Ub9zMDjt8Q/2h433mUVbId4nQupd7uZX1/VH4iWAnlxtsHdPsdwSFZjVSp+l
psTfKMurryiNe3VhGx1nWlNv4gofiGWRJcAvQfFgJ1pqJcTUQPIePlBv1ol17Hws
GIHF80Mj7BvLLjFerGqS7gvozAC+Z07pDUChR0ttr95cXETfO22rcpCWX20rnA8O
5RMXghGRGPC5OvW4QHWalZoybbipSyxRzVF6K9EAJN8dKi4xBw3TtCewHo9q7Yau
KyccnxcvME5DgZoeNdE4DTdyHxojY3cJbaMUxKTxvRCs4KfCErOXaoIl45hWcp4Y
sKi4RpCEhAkCpKyRtT3j
=DSFu
-----END PGP SIGNATURE-----

--t4k3FX2BKM3OLyzG--

--===============0057334213141686048==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0057334213141686048==--
