From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH linux-next] dmaengine: add context
	parameter fixups
Date: Sat, 24 Mar 2012 00:53:20 +0000
Message-ID: <20120324005320.GB3190@opensource.wolfsonmicro.com>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4441734946561899614=="
Cc: fabio.estevam@freescale.com, alsa-devel@alsa-project.org, samuel@sortiz.org,
	vinod.koul@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	linux-next@vger.kernel.org, tiwai@suse.de,
	dan.j.williams@intel.com, lrg@ti.com
To: Alexandre Bounine <alexandre.bounine@idt.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
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


--===============4441734946561899614==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Content-Disposition: inline


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Mar 23, 2012 at 10:00:42AM -0400, Alexandre Bounine wrote:
> This patch fixes drivers that use device_prep_slave_sg() and
> device_prep_dma_cyclic() interfaces and have been missed during the initial
> release of interface changing patches.

Can you please send a separate patch for the ASoC (sound/soc) bits of
this?

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPbRr2AAoJEBus8iNuMP3d4BcP/RpL0AxKVsJNqh9SMqEmiC+1
TL67nLDRzfaSIVHHB5Yop94htNAw04YcjtEbkH6e5CbA05nCl1tCsOiQSbjtaqXY
9qiKYCz3CA7YP7uv4KanMYI+2hSGlmgsRBJbr0Q7BGXb8mO2hX/qbh5lYf+RQInr
/RFQsH5f/eV7HXdDJeKyZtYaaU8XB6oCQ/CgOj6rGcb9Qm2f4Di6eH8ugD7/aPxV
dYqMuBwxGbDJHd+B1CoNQOzwEChemHzcP1Bwfj/dTdbiyqmhLUtTsjFV8ukb03uH
czahRelRMBEn+MSua78dOpR+KlVCO8kQiiPSYcXyu/jvEIk7JvmoYCJM99HxwYqq
kKhoLvitK7buq6saku/GfRIZP++GFlvvXhl/i5bHIjy/xmHRXLE+87IIqt1FtiVm
sq1OPT+p0qKvYFGRzEBwHPfE0Sr90TLk79unzx1ec3pLGGMZHwVX8OzbhkJ0wQ4J
c0UHS2Z0QcMcASmQ5yjJmfV7ZmT7d8KfyfZkB1AxGynZs4YO7Gf6ek9+g/CQV+wf
AiiDsPzo8WQbc0yphfC5lQLRIb9XqO9xwTQStOAcJcelahOrP+JgI/c89/HlXjSw
mru6IHCa6rsqOF8UHGXs3ty876dfYwG/IjqB5Xui5Hg4eITIeQmgPYHpH37VVwPp
27z2KTXSictKNvlinuLY
=4ghL
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--

--===============4441734946561899614==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============4441734946561899614==--
