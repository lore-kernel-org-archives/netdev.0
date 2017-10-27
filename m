From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: wcn36xx: Remove unnecessary rcu_read_unlock in
 wcn36xx_bss_info_changed
Date: Fri, 27 Oct 2017 16:00:41 +0200
Message-ID: <884b0ccc727549b28df7f3705081f67a@euamsexm01a.eu.qualcomm.com>
References: <1507467969-24016-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        <wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507467969-24016-1-git-send-email-baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> wrote:

> No rcu_read_lock is called, but rcu_read_unlock is still called.
> Thus rcu_read_unlock should be removed.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
> Acked-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>

Patch applied to ath-current branch of ath.git, thanks.

c0d5adc35c0b wcn36xx: Remove unnecessary rcu_read_unlock in wcn36xx_bss_info_changed

-- 
https://patchwork.kernel.org/patch/9991827/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
