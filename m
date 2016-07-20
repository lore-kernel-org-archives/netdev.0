From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth-next 2016-07-19
Date: Wed, 20 Jul 2016 14:44:43 -0700 (PDT)
Message-ID: <20160720.144443.401615378058083843.davem@davemloft.net>
References: <20160719061452.GA21654@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mchehab-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160719061452.GA21654-ae+CCJ+dGXjCW7GOcxkI+ioyn5ZhHHrn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 19 Jul 2016 09:14:52 +0300

> Here's likely the last bluetooth-next pull request for the 4.8 kernel:
> 
>  - Fix for L2CAP setsockopt
>  - Fix for is_suspending flag handling in btmrvl driver
>  - Addition of Bluetooth HW & FW info fields to debugfs
>  - Fix to use int instead of char for callback status.
> 
> The last one (from Geert Uytterhoeven) is actually not purely a
> Bluetooth (or 802.15.4) patch, but it was agreed with other maintainers
> that we take it through the bluetooth-next tree.
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks.
