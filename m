From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: add Netgear AirCard 341U
Date: Thu, 29 May 2014 12:00:53 +0200
Message-ID: <877g54dhuy.fsf@nemi.mork.no>
References: <1401303903-29958-1-git-send-email-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36648 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723AbaE2KA4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 06:00:56 -0400
In-Reply-To: <1401303903-29958-1-git-send-email-aleksander@aleksander.es>
	(Aleksander Morgado's message of "Wed, 28 May 2014 21:05:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aleksander Morgado <aleksander@aleksander.es> writes:

> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
> ---
>  drivers/net/usb/qmi_wwan.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 83208d4..c0b611f 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -753,6 +753,7 @@ static const struct usb_device_id products[] =3D =
{
>  	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 *=
/
>  	{QMI_FIXED_INTF(0x1199, 0x9041, 8)},	/* Sierra Wireless MC7305/MC73=
55 */
>  	{QMI_FIXED_INTF(0x1199, 0x9051, 8)},	/* Netgear AirCard 340U */
> +	{QMI_FIXED_INTF(0x1199, 0x9055, 8)},	/* Netgear AirCard 341U */
>  	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (=
Alcatel One Touch L100V LTE) */
>  	{QMI_FIXED_INTF(0x1bbb, 0x0203, 2)},	/* Alcatel L800MA */
>  	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 *=
/

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
