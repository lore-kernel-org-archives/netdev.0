From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] net: sierra: shut up sparse restricted type
 warnings
Date: Sun, 28 Oct 2012 19:09:13 -0400 (EDT)
Message-ID: <20121028.190913.1707342391951257053.davem@davemloft.net>
References: <1351237449-23643-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351237449-23643-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 26 Oct 2012 09:44:07 +0200

> Removes the warnings
>=20
>  drivers/net/usb/sierra_net.c:343:45: warning: incorrect type in assi=
gnment (different base types)
>  drivers/net/usb/sierra_net.c:343:45:    expected unsigned short [uns=
igned] [short] [usertype] <noident>
>  drivers/net/usb/sierra_net.c:343:45:    got restricted __be16 [usert=
ype] <noident>
>=20
> and
>=20
>  drivers/net/usb/sierra_net.c:658:18: warning: cast to restricted __l=
e16
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
