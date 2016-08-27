From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth 2016-08-25
Date: Fri, 26 Aug 2016 21:10:05 -0700 (PDT)
Message-ID: <20160826.211005.1840302554943486711.davem@davemloft.net>
References: <20160825191746.GA16954@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160825191746.GA16954-ae+CCJ+dGXjCW7GOcxkI+ioyn5ZhHHrn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 25 Aug 2016 22:17:46 +0300

> Here are a couple of important Bluetooth fixes for the 4.8 kernel:
> 
>  - Memory leak fix for HCI requests
>  - Fix sk_filter handling with L2CAP
>  - Fix sock_recvmsg behavior when MSG_TRUNC is not set
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
