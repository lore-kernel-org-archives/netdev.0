From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 00/28] MIPS Boston board support
Date: Mon, 30 Nov 2015 16:34:13 +0000
Message-ID: <20151130163413.GB1929@sirena.org.uk>
References: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="pI6hLdwVzam1XFuA"
Cc: linux-mips@linux-mips.org, Arnd Bergmann <arnd@arndb.de>,
        Joshua Kinard <kumba@gentoo.org>,
        Alessandro Zummo <a.zummo@towertech.it>,
        Jiri Slaby <jslaby@suse.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        Kumar Gala <galak@codeaurora.org>,
        Yijing Wang <wangyijing@huawei.com>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Rob Herring <robh+dt@kernel.org>,
        John Crispin <blogic@openwrt.org>,
        Jayachandran C <jchandra@broadcom.com>,
        linux-spi@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Ray Jui <rjui@broadcom.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Tejun Heo <tj@kernel.org>,
        Michal Simek <michal.simek@xilinx.com>,
        Andrew
To: Paul Burton <paul.burton@imgtec.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org


--pI6hLdwVzam1XFuA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 30, 2015 at 04:21:25PM +0000, Paul Burton wrote:
> This series introduces support for the Imagination Technologies MIPS
> Boston development board. Boston is an FPGA-based development board
> akin to the much older Malta board, built around a Xilinx FPGA running
> a MIPS CPU & other logic including a PCIe root port connected to an
> Intel EG20T Platform Controller Hub. This provides a base set of
> peripherals including SATA, USB, SD/MMC, ethernet, I2C & GPIOs. PCIe
> slots are also present for expansion.

This is an insanely big CC list :(

What are the interdependencies here - does this really need to be one
patch series or can the individual driver changes go in separately?  The
latter is more normal, usually rather than a single patch series we just
have each driver sent by itself since that's usually easier to handle
and avoids the massive CC lists.

--pI6hLdwVzam1XFuA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWXHqEAAoJECTWi3JdVIfQJSUH/iIgPfd2b5fhUdpCuloKrkzo
ez7mkxbm3A2j3pKg0G57M4IEOD1UHHBQdACn9Gn38+UCLVdK2VoDpY+xxpf0bUbB
aWm0a1vnjxwyTW5lSEkeR0i6EzMuFliUJnIsdv9yrmwUdm8Z0zJTYaLRm2rKsgR3
kQLDe+kzzuf3qKW0mVcOL8y4rb/keG79c35wSXn4heWbFL7FCAUmVZ0bhcOkeLP+
O9T7D/fqnlT4+gOvBBlglzHBjWY8JUYJiccHFfccRZJ3hOO973bHQi8QcGhS06C3
LFww/Secx7tTiUXfdXo5sD0dAJwN7mG8sBrYAmZPBcW1TYn6wzCxFMK9XkLVA9k=
=7ym9
-----END PGP SIGNATURE-----

--pI6hLdwVzam1XFuA--
