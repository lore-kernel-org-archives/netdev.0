From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] ath: change logging functions to return void
Date: Mon, 29 Sep 2014 14:28:42 +0300
Message-ID: <87h9zq1x91.fsf@kamboji.qca.qualcomm.com>
References: <1411407334.2952.46.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: wil6210 <wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Vladimir Kondratiev <qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	<ath6kl-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411407334.2952.46.camel@joe-AO725> (Joe Perches's message of
	"Mon, 22 Sep 2014 10:35:34 -0700")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:

> The return values are not used by callers of these functions
> so change the functions to return void.
>
> Other miscellanea:
>
> o add __printf verification to wil6210 logging functions
>   No format/argument mismatches found
>
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Thanks, applied.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
