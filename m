From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] NFC: remove pointless conditional before kfree_skb()
Date: Fri, 7 Sep 2012 18:48:58 +0200
Message-ID: <20120907164858.GE3647@sortiz-mobl>
References: <CAPgLHd80nD+uYpMMC+sLjcErRcLbGpAVMw7PktrAoxJB8NwHsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org, aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAPgLHd80nD+uYpMMC+sLjcErRcLbGpAVMw7PktrAoxJB8NwHsg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wei,

On Tue, Aug 28, 2012 at 09:02:40PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> 
> Remove pointless conditional before kfree_skb().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> ---
>  net/nfc/hci/shdlc.c | 3 +--
>  net/nfc/hci/core.c  | 3 +--
>  2 files changed, 2 insertions(+), 4 deletions(-)
Thanks, patch applied to my nfc-next branch.

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
