From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: ath9k: debug: Remove redundant check
Date: Fri, 27 Oct 2017 15:50:43 +0200
Message-ID: <950220104459484c9610cd0fc7ac3ca6@euamsexm01a.eu.qualcomm.com>
References: <1507974371-7419-1-git-send-email-chris.gekas@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Christos Gkekas <chris.gekas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Christos Gkekas <chris.gekas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507974371-7419-1-git-send-email-chris.gekas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christos Gkekas <chris.gekas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Variable val is unsigned, so checking whether it is less than zero is
> redundant.
> 
> Signed-off-by: Christos Gkekas <chris.gekas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>

Patch applied to ath-next branch of ath.git, thanks.

9d414949a306 ath9k: debug: Remove redundant check

-- 
https://patchwork.kernel.org/patch/10006341/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
