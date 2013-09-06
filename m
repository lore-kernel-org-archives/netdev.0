From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] Add missing braces to ath10k_pci_tx_pipe_cleanup
Date: Fri, 6 Sep 2013 12:32:43 +0300
Message-ID: <87mwnqi9c4.fsf@kamboji.qca.qualcomm.com>
References: <20130905035128.GA15824@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130905035128.GA15824-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Dave Jones's message of
	"Wed, 4 Sep 2013 23:51:28 -0400")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> The indentation here implies this was meant to be a multi-statement
> if, but it lacks the braces.
>
> Signed-off-by: Dave Jones <davej-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>

Thanks, applied.

I added "ath10k:" to the patch title.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
