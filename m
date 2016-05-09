From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next 4/5] treewide: replace dev->trans_start update
 with helper
Date: Mon, 9 May 2016 09:12:51 +0200
Message-ID: <57303873.5000108@pengutronix.de>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
 <1462285994-31983-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="fcr4wLrDMdGPahnJScwefNsWCeJgfIRNI"
Cc: user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org,
	linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	MPT-FusionLinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462285994-31983-1-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fcr4wLrDMdGPahnJScwefNsWCeJgfIRNI
Content-Type: multipart/mixed; boundary="GFLu7KIgkl64MDwwCs6gU46kBmw2cCDDs"
From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
 linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
 linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, MPT-FusionLinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <57303873.5000108-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next 4/5] treewide: replace dev->trans_start update
 with helper
References: <1462285862-30946-1-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
 <1462285994-31983-1-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <1462285994-31983-1-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>

--GFLu7KIgkl64MDwwCs6gU46kBmw2cCDDs
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/03/2016 04:33 PM, Florian Westphal wrote:
> Replace all trans_start updates with netif_trans_update helper.
> change was done via spatch:
>=20
> struct net_device *d;
> @@
> - d->trans_start =3D jiffies
> + netif_trans_update(d)
>=20
> Compile tested only.
>=20
> Cc: user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> Cc: linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org
> Cc: linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: MPT-FusionLinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
> Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org
> Cc: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
> Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
> ---
>  Checkpatch complains about whitespace damage, but
>  this extra whitespace already exists before this patch.
>=20
>  drivers/net/can/mscan/mscan.c                          | 4 ++--
>  drivers/net/can/usb/ems_usb.c                          | 4 ++--
>  drivers/net/can/usb/esd_usb2.c                         | 4 ++--
>  drivers/net/can/usb/peak_usb/pcan_usb_core.c           | 4 ++--

> diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/msca=
n.c
> index e36b740..acb708f 100644
> --- a/drivers/net/can/mscan/mscan.c
> +++ b/drivers/net/can/mscan/mscan.c
> @@ -276,7 +276,7 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff =
*skb, struct net_device *dev)
>  	out_8(&regs->cantflg, 1 << buf_id);
> =20
>  	if (!test_bit(F_TX_PROGRESS, &priv->flags))
> -		dev->trans_start =3D jiffies;
> +		netif_trans_update(dev);
> =20
>  	list_add_tail(&priv->tx_queue[buf_id].list, &priv->tx_head);
> =20
> @@ -469,7 +469,7 @@ static irqreturn_t mscan_isr(int irq, void *dev_id)=

>  			clear_bit(F_TX_PROGRESS, &priv->flags);
>  			priv->cur_pri =3D 0;
>  		} else {
> -			dev->trans_start =3D jiffies;
> +			netif_trans_update(dev);
>  		}
> =20
>  		if (!test_bit(F_TX_WAIT_ALL, &priv->flags))
> diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_us=
b.c
> index 3400fd1..71f0e79 100644
> --- a/drivers/net/can/usb/ems_usb.c
> +++ b/drivers/net/can/usb/ems_usb.c
> @@ -521,7 +521,7 @@ static void ems_usb_write_bulk_callback(struct urb =
*urb)
>  	if (urb->status)
>  		netdev_info(netdev, "Tx URB aborted (%d)\n", urb->status);
> =20
> -	netdev->trans_start =3D jiffies;
> +	netif_trans_update(netdev);
> =20
>  	/* transmission complete interrupt */
>  	netdev->stats.tx_packets++;
> @@ -835,7 +835,7 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buf=
f *skb, struct net_device *ne
>  			stats->tx_dropped++;
>  		}
>  	} else {
> -		netdev->trans_start =3D jiffies;
> +		netif_trans_update(netdev);
> =20
>  		/* Slow down tx path */
>  		if (atomic_read(&dev->active_tx_urbs) >=3D MAX_TX_URBS ||
> diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_u=
sb2.c
> index 113e64f..784a900 100644
> --- a/drivers/net/can/usb/esd_usb2.c
> +++ b/drivers/net/can/usb/esd_usb2.c
> @@ -480,7 +480,7 @@ static void esd_usb2_write_bulk_callback(struct urb=
 *urb)
>  	if (urb->status)
>  		netdev_info(netdev, "Tx URB aborted (%d)\n", urb->status);
> =20
> -	netdev->trans_start =3D jiffies;
> +	netif_trans_update(netdev);
>  }
> =20
>  static ssize_t show_firmware(struct device *d,
> @@ -820,7 +820,7 @@ static netdev_tx_t esd_usb2_start_xmit(struct sk_bu=
ff *skb,
>  		goto releasebuf;
>  	}
> =20
> -	netdev->trans_start =3D jiffies;
> +	netif_trans_update(netdev);
> =20
>  	/*
>  	 * Release our reference to this URB, the USB core will eventually fr=
ee
> diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net=
/can/usb/peak_usb/pcan_usb_core.c
> index 5a2e341..bfb91d8 100644
> --- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> @@ -274,7 +274,7 @@ static void peak_usb_write_bulk_callback(struct urb=
 *urb)
>  		netdev->stats.tx_bytes +=3D context->data_len;
> =20
>  		/* prevent tx timeout */
> -		netdev->trans_start =3D jiffies;
> +		netif_trans_update(netdev);
>  		break;
> =20
>  	default:
> @@ -373,7 +373,7 @@ static netdev_tx_t peak_usb_ndo_start_xmit(struct s=
k_buff *skb,
>  			stats->tx_dropped++;
>  		}
>  	} else {
> -		netdev->trans_start =3D jiffies;
> +		netif_trans_update(netdev);
> =20
>  		/* slow down tx path */
>  		if (atomic_read(&dev->active_tx_urbs) >=3D PCAN_USB_MAX_TX_URBS)

For the drivers/can part:

Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

regards,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--GFLu7KIgkl64MDwwCs6gU46kBmw2cCDDs--

--fcr4wLrDMdGPahnJScwefNsWCeJgfIRNI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXMDhzAAoJED07qiWsqSVqY58H/ix0AbZ+YrFYM2PIOprS2fXE
aX27+KlnttkKPZwwfFINkn2/zij9PmEHqTEIhWIQW+jkvzw3wk2+4r7S6RgCasja
uYAWpyo35ikxuaRPe9rzVseGZfULqW5rGxx5I9fp9eC4WFjyU66mwhWI08YY2apl
W1Lqfgzz2Op2wykMdjjjW9bjnDQLigGgdvjsvg03u0hyPhfWol23c3UexJU13qXJ
blCUgZ3l3JJeh3FsZlb1wJ08j4imD54l2H+/y3uDNEh9V3k40pTtDxWoRwx3wc1C
Q6gJ1MowW9/sLy+VOcMrFLy4JG652SUKe1B0pNocQX7QjHvQkt7pTtdx3reGwmM=
=cJdV
-----END PGP SIGNATURE-----

--fcr4wLrDMdGPahnJScwefNsWCeJgfIRNI--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
