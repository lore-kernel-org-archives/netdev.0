From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2011-04-25
Date: Thu, 28 Apr 2011 20:31:00 -0700 (PDT)
Message-ID: <20110428.203100.193725173.davem@davemloft.net>
References: <20110425.130435.112597353.davem@davemloft.net>
	<4DB5DFBC.3070203@lwfinger.net>
	<20110429031143.GA2353@joana>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110429031143.GA2353@joana>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Date: Fri, 29 Apr 2011 00:11:43 -0300

> * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> [2011-04-25 15:55:24 -0500]:
> 
>> Unfortunately, the 64-bit variant of gcc v4.5.1 will miss some of these. I find 
>> I need to compile code on a 32-bit system and using an older compiler to catch 
>> all. Perhaps that explains the error that crept through here.
> 
> That could be a reason, I have gcc 4.5.2 (64-bit). I've built this code many times
> before send pull request and never saw that warning, and it's clearly a bug,
> indeed. 

I would buy this line of reasoning.

Except that I do all of my test builds with 64-bit gcc's, on sparc64
and x86-64.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
