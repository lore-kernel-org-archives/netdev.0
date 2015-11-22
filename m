From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v2 00/27] wireless drivers vendor directories
Date: Sun, 22 Nov 2015 19:30:12 +0200
Message-ID: <87h9kerlgb.fsf@kamboji.qca.qualcomm.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> (Kalle
	Valo's message of "Wed, 18 Nov 2015 16:45:39 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> writes:

> Hi,
>
> I started to reorganise drivers/net/wireless directory and follow what
> drivers/net/ethernet has. The major change is that new vendor
> directories are created and most of the drivers are now under those
> vendor directories:
>
> admtek/
> ath/
> atmel/
> broadcom/
> cisco/
> intel/
> intersil/
> marvell/
> mediatek/
> ralink/
> realtek/
> rsi/
> st/
> ti/
> zydas/
>

[...]

> Kalle Valo (27):
>   adm80211: move under admtek vendor directory
>   airo: move under cisco vendor directory
>   atmel: move under atmel vendor directory
>   b43: move under broadcom vendor directory
>   b43legacy: move under broadcom vendor directory
>   brcm80211: move under broadcom vendor directory
>   cw1200: move under st vendor directory
>   ipw2x00: move under intel vendor directory
>   iwlegacy: move under intel directory
>   iwlwifi: move under intel vendor directory
>   libertas: move under marvell vendor directory
>   libertas_tf: move under marvell vendor directory
>   mwifiex: move under marvell vendor directory
>   mwl8k: move under marvell vendor directory
>   zd1201: move under zydas vendor directory
>   zd1211rw: move under zydas vendor directory
>   hostap: move under intersil vendor directory
>   p54: move under intersil vendor directory
>   orinoco: move under intersil vendor directory
>   prism54: move under intersil vendor directory
>   realtek: create separate Kconfig file
>   rsi: add vendor Kconfig entry
>   rt2x00: move under ralink vendor directory
>   mediatek: unify Kconfig with other vendors
>   ti: unify Kconfig with other vendors
>   ath: unify Kconfig with other vendors
>   mac80211_hwsim: move Kconfig entry for sorting alphabetically

Applied to wireless-drivers-next.git.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
