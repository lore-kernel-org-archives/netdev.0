From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v6 00/10] ARM: Berlin: Ethernet support
Date: Fri, 26 Sep 2014 16:37:37 +0200
Message-ID: <20140926143737.GA23559@kwain>
References: <1411742036-23520-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1411742036-23520-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 04:33:46PM +0200, Antoine Tenart wrote:
> Hi all,
>=20
> This series introduce support for the Ethernet controller on Berlin S=
oCs,
> using the existing pxa168 Ethernet driver. In order to do this, DT
> support is added to the driver alongside some other modifications and
> fixes.
>=20
> This has been tested on a Berlin BG2Q DMP board.
>=20
> Changes since v4:
> 	- removed the phy-addr property and added a phy subnode
> 	- added COMPILE_TEST for the pxa168_eth driver
>=20
> Changes since v3:
>         - moved the addition of pxa168_eth_get_mac_address() to the p=
atch
>           using it first
>=20
> Changes since v2:
>         - reworked how the MAC address is configured
>         - made the clock anonymous
>=20
> Changes since v1:
>         - removed custom Berlin Ethernet driver
>         - used the pxa168 Ethernet driver instead
>         - made modifications to the pxa168 driver (DT support, fixes)
>=20

That's really the cover letter for the v5, not v6, I made a typo in the
subject...

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
