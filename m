From: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Subject: Re: hostap: Delete an unnecessary jump label in
 prism2_ioctl_priv_hostapd()
Date: Mon, 26 Sep 2016 18:03:00 +0200
Message-ID: <88d5023a-9a59-ab36-8c6c-a146cae803b5@users.sourceforge.net>
References: <65ed528f-7ec5-a0f2-6219-3e63a78ca0ee@users.sourceforge.net>
 <20160926150656.213D961568@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jouni Malinen <j@w1.fi>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160926150656.213D961568-4h6buKAYkuurB/BPivuO70B+6BGkLq7r@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> 9291771 [2/3] hostap: Delete an unnecessary jump label in prism2_ioctl_priv_hostapd()
> 9291775 [3/3] hostap: Delete unnecessary initialisations for the variable "ret"
> 
> Reason: The benefit is not clear.

How do you think about to reduce the source code a bit at these places?

Regards,
Markus
