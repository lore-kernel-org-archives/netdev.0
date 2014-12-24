From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH next] drivers/net/wireless/ath/wil6210/debugfs.c: Use 'uint64_t' instead of 'cycles_t' to avoid warnings
Date: Wed, 24 Dec 2014 17:11:16 +0200
Message-ID: <8761d19j6z.fsf@kamboji.qca.qualcomm.com>
References: <549AD067.80608@gmail.com> <549AD54F.3020605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <549AD54F.3020605-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Chen Gang's message of "Wed, 24 Dec
	2014 23:01:35 +0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Oh, sorry, I forgot the word wrap (after change a new pc). I shall send
> patch v2 for it.

While at it, could you also please simplify the title. You don't have to
put the full directory there, it just makes it more difficult to read.
This should be enough:

wil6210: Use 'uint64_t' instead of 'cycles_t' to avoid warnings

I see quite a few patches with titles like 'drivers: net: wireless: ath:
fix foo'. Where an earth is that coming from? Bad documentation
somewhere?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
