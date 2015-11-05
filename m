From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] USB: qmi_wwan: Add quirk for Quectel EC20 Mini PCIe
 module
Date: Thu, 05 Nov 2015 11:40:28 -0500 (EST)
Message-ID: <20151105.114028.1294088625259119099.davem@davemloft.net>
References: <1446720952-15635-1-git-send-email-ynezz@true.cz>
	<1446724501-18821-1-git-send-email-ynezz@true.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ynezz-knWk7/PSn+s@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1446724501-18821-1-git-send-email-ynezz-knWk7/PSn+s@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Petr =A6tetiar <ynezz-knWk7/PSn+s@public.gmane.org>
Date: Thu,  5 Nov 2015 12:55:01 +0100

> This device has same vendor and product IDs as G2K devices, but it ha=
s
> different number of interfaces(4 vs 5) and also different interface
> layout where EC20 has QMI on interface 4 instead of 0.
>=20
> lsusb output:
 ...
> Signed-off-by: Petr =A6tetiar <ynezz-knWk7/PSn+s@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
