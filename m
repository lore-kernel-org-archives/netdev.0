From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/6] net: qmi_wwan: MDM9x30 support
Date: Fri, 04 Dec 2015 16:56:50 -0500 (EST)
Message-ID: <20151204.165650.2179782476717882268.davem@davemloft.net>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, oneukum-IBi9RG/b67k@public.gmane.org, aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org,
	dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Thu,  3 Dec 2015 19:24:17 +0100

> We add new device IDs all the time, often without any testing on
> actual hardware. This is usually OK as long as the device is similar
> to already supported devices, using the same chipset and firmware
> basis.  But the Sierra Wireless MC7455 is an example of a new chipset
> generation. Adding it based on assumed similarity with its ancestors
> proved too optimistic.
>=20
> This series adds the missing bits and pieces necessary to support LTE
> Advanced modems based on the Qualcomm MDM9x30 chipset. A big thanks t=
o
> Sierra Wireless for providing MC7455 samples for testing

Series applied to net-next, thanks a lot.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
