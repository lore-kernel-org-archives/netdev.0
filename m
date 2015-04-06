From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth-next 2015-04-04
Date: Mon, 06 Apr 2015 17:15:38 -0400 (EDT)
Message-ID: <20150406.171538.1861592247290486681.davem@davemloft.net>
References: <20150404062406.GA29882@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150404062406.GA29882-ae+CCJ+dGXjCW7GOcxkI+ioyn5ZhHHrn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sat, 4 Apr 2015 09:24:06 +0300

> Here's what's probably the last bluetooth-next pull request for 4.1:
> 
>  - Fixes for LE advertising data & advertising parameters
>  - Fix for race condition with HCI_RESET flag
>  - New BNEPGETSUPPFEAT ioctl, needed for certification
>  - New HCI request callback type to get the resulting skb
>  - Cleanups to use BIT() macro wherever possible
>  - Consolidate Broadcom device entries in the btusb HCI driver
>  - Check for valid flags in CMTP, HIDP & BNEP
>  - Disallow local privacy & OOB data combo to prevent a potential race
>  - Expose SMP & ECDH selftest results through debugfs
>  - Expose current Device ID info through debugfs
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
