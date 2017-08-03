From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [net] hostap: Fix outdated comment about dev->destructor
Date: Thu,  3 Aug 2017 10:08:54 +0000 (UTC)
Message-ID: <20170803100854.D9AE560763@smtp.codeaurora.org>
References: <0824ed85fd45846da65fc919ae22df9d7ebf2f97.1501150507.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Jouni Malinen <j@w1.fi>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0824ed85fd45846da65fc919ae22df9d7ebf2f97.1501150507.git.sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> After commit cf124db566e6 ("net: Fix inconsistent teardown and
> release of private netdev state."), setting
> 'dev->needs_free_netdev' ensures device data is released, and
> 'dev->destructor' is not used anymore.
> 
> Fixes: cf124db566e6 ("net: Fix inconsistent teardown and release of private netdev state.")
> Signed-off-by: Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

9ff067ff4c4a hostap: Fix outdated comment about dev->destructor

-- 
https://patchwork.kernel.org/patch/9866663/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
