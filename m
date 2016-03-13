From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2016-03-09
Date: Sun, 13 Mar 2016 15:04:54 -0400 (EDT)
Message-ID: <20160313.150454.1285398123514574559.davem@davemloft.net>
References: <87vb4vpga7.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87vb4vpga7.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Date: Wed, 09 Mar 2016 22:06:40 +0200

> here's a pull request for 4.6. I'm planning to send one more but I'm not
> sure if it will make it in time, we'll see.
> 
> Here notable changes are refactoring in bcma to create a common flash
> driver, brcmfmac platform data improvements in include/linux and
> beginning of AHB bus support for ath10k along with device tree binding
> update. More info in the signed tag below.
> 
> Oh, and I just noticed that weirdly my name appeared in author field on
> one of Janusz' ath9k patches. But I didn't consider this bad enough to
> rebase everything so I let it be. Sorry Janusz :)
> 
> commit b9a9693fd9aea43f50b107dfc8cbaea317f95a79
> Author: Kalle Valo <Janusz.Dziedzic-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
> Date:   Fri Nov 27 09:37:14 2015 +0100
> 
>     ath9k: request NOA update when chanctx active
> 
> Please let me know if you have any problems.

Yeah it's always an unfortunate tradeoff when something in the commit
history of a tree everyone clones and works against turns out to be
incorrect :-/

Pulled, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
