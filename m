From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 0/3] b43: logging cleanups
Date: Thu, 24 Jun 2010 14:20:58 -0500
Message-ID: <4C23B01A.6020901@lwfinger.net>
References: <cover.1276988387.git.joe@perches.com> <20100624185339.GC2368@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100624185339.GC2368-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/24/2010 01:53 PM, John W. Linville wrote:
> On Sat, Jun 19, 2010 at 04:30:08PM -0700, Joe Perches wrote:
>> Just some small cleanups
>>
>> Joe Perches (3):
>>   drivers/net/wireless/b43: Use local ratelimit_state
>>   drivers/net/wireless/b43: Logging cleanups
>>   drivers/net/wireless/b43: Rename b43_debug to b43_debugging
> 
> Any of the b43 guys want to express an opinion on these?

The local ratelimit patch is OK. My personal opinion is that the others
are just churning the source for no real reason, but I have no major
objections.

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
