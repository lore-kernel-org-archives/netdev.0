From: qca_dlansky <qca_dlansky-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Subject: RE: linux-4.11-rc5/drivers/net/wireless/ath/wil6210/pmc.c: 2 * poor
 place for limits check ?
Date: Mon, 3 Apr 2017 19:30:23 +0000
Message-ID: <d2d7047c4e7b4931b77a82aaf43e2abb@euamsexm01b.eu.qualcomm.com>
References: <HE1PR0801MB1865948355B11C9E63315D2F9C080@HE1PR0801MB1865.eurprd08.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: David Binderman <dcb314-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
        qca_merez <qca_merez-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        "kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        wil6210 <wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <HE1PR0801MB1865948355B11C9E63315D2F9C080-TrivKwPZaC6VEZXSXRKha0dOKmgb957onBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Binderman [mailto:dcb314-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org]=20
Sent: Monday, April 3, 2017 2:16 PM

>
> Hello there,
>
> 1.
>
> linux-4.11-rc5/drivers/net/wireless/ath/wil6210/pmc.c:188]: (style) Array=
 index 'i' is used before limits check.

Thanks for letting us know.
We'll upload a fix soon.

Thanks,
 Dedy.
