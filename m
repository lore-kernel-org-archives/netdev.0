From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 00/51] DMA mask changes
Date: Thu, 26 Sep 2013 22:23:08 +0200
Message-ID: <CACna6rxkpYzdD8_Jfi22vA2suUa3k-JM65_gCySQpp4crVCoPg@mail.gmail.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alsa-devel@alsa-project.org, b43-dev <b43-dev@lists.infradead.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	devicetree@vger.kernel.org,
	dri-devel <dri-devel@lists.freedesktop.org>,
	e1000-devel@lists.sourceforge.net,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fbdev@vger.kernel.org, linux-ide@vger.kernel.org,
	linux-media@vger.kernel.org, linux-mmc@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-omap@vger.kernel.org,
	linux ppc dev <linuxppc-dev@lists.ozlabs.org>,
	linux-samsung-soc@vger.kernel.org,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	linux-tegra@vger.kernel.org, linux-usb@vger.kernel.org,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-ne
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/9/19 Russell King - ARM Linux <linux@arm.linux.org.uk>:
> This email is only being sent to the mailing lists in question, not t=
o
> anyone personally.  The list of individuals is far to great to do tha=
t.
> I'm hoping no mailing lists reject the patches based on the number of
> recipients.

Huh, I think it was enough to send only 3 patches to the b43-dev@. Like=
:
[PATCH 01/51] DMA-API: provide a helper to set both DMA and coherent DM=
A masks
[PATCH 14/51] DMA-API: net: b43: (...)
[PATCH 15/51] DMA-API: net: b43legacy: (...)
;)

I believe Joe has some nice script for doing it that way. When fixing
some coding style / formatting, he sends only related patches to the
given ML.

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-omap" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
