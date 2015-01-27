From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-01-22
Date: Mon, 26 Jan 2015 16:12:10 -0800 (PST)
Message-ID: <20150126.161210.78215547165591571.davem@davemloft.net>
References: <87h9vjnic4.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87h9vjnic4.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Date: Thu, 22 Jan 2015 13:52:11 +0200

> now a bigger pull request for net-next. Rafal found a UTF-8 bug in
> patchwork[1] and because of that two commits (d0c102f70aec and
> d0f66df5392a) have his name corrupted:
> 
>     Acked-by: Rafa? Mi?ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Somehow I failed to spot that when I commited the patches. As rebasing
> public git trees is bad, I thought we can live with these and decided
> not to rebase. But I'll pay close attention to this in the future to
> make sure that it won't happen again. Also we requested an update to
> patchwork.kernel.org, the latest patchwork doesn't seem to have this
> bug.
> 
> Also please note this pull request also adds one DT binding doc, but
> this was reviewed in the device tree list:
> 
>  .../bindings/net/wireless/qcom,ath10k.txt          |   30 +
> 
> Please let me know if you have any issues.

Pulled, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
