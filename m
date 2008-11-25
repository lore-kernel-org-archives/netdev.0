From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH/RFC v1 00/12] Support for Broadcom 63xx SOCs
Date: Tue, 25 Nov 2008 18:44:26 +0100
Message-ID: <200811251844.27405.florian@openwrt.org>
References: <1224382022-24173-1-git-send-email-mbizon@freebox.fr> <200810221558.27338.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	afleming@freescale.com, jgarzik@pobox.com,
	linux-usb@vger.kernel.org, dbrownell@users.sourceforge.net,
	linux-pcmcia@lists.infradead.org, linux-serial@vger.kernel.org,
	linux-mips@linux-mips.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <200810221558.27338.florian@openwrt.org>
Content-Disposition: inline
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again,

Le Wednesday 22 October 2008 15:58:23 Florian Fainelli, vous avez =E9cr=
it=A0:
> I prefer you get some feedback on your patches first before submittin=
g my
> changes.

So the OpenWrt community did the following succesful tests :

- Inventel Livebox Pro (Need the OpenWrt patches plus some glue code to=
=20
retrieve the MAC address) (6348)
- Neufbox 4 (6358)
- Comtrend CT536+ (6348)
- A custom design based on a BCM6348

There might be other successful reports as well.
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
--
To unsubscribe from this list: send the line "unsubscribe linux-serial"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
