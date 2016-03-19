From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: btcoexist: Convert BTC_PRINTK to btc_<foo>_dbg
Date: Sat, 19 Mar 2016 11:09:50 +0200
Message-ID: <87pouqhm01.fsf@kamboji.qca.qualcomm.com>
References: <4672f9efb37df545ae504d51ca626bf34237fa63.1458258337.git.joe@perches.com>
	<56EB6DD9.3000300@lwfinger.net> <1458272258.9556.46.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458272258.9556.46.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> (Joe Perches's message of
	"Thu, 17 Mar 2016 20:37:38 -0700")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:

> On Thu, 2016-03-17 at 21:54 -0500, Larry Finger wrote:
>> On 03/17/2016 07:00 PM, Joe Perches wrote:
>> > Use a more common logging style.
>
> [ 300K+ quote without comment ]

Yeah, please try to avoid that. For example this makes the patchwork
page for the patch really hard to read:

https://patchwork.kernel.org/patch/8615131/

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
