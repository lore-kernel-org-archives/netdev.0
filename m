From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth-next 2015-03-14
Date: Sat, 14 Mar 2015 14:30:09 -0400 (EDT)
Message-ID: <20150314.143009.2216331232217010224.davem@davemloft.net>
References: <20150314180144.GA22474@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150314180144.GA22474-ae+CCJ+dGXjCW7GOcxkI+ioyn5ZhHHrn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sat, 14 Mar 2015 20:01:44 +0200

> Here's another set of Bluetooth & ieee802154 patches intended for 4.1:
> 
>  - Added support for QCA ROME chipset family in the btusb driver
>  - at86rf230 driver fixes & cleanups
>  - ieee802154 cleanups
>  - Refactoring of Bluetooth mgmt API to allow new users
>  - New setting for static Bluetooth address exposed to user space
>  - Refactoring of hci_dev flags to remove limit of 32
>  - Remove unnecessary fast-connectable setting usage restrictions
>  - Fix behavior to be consistent when trying to pair already paired device
>  - Service discovery corner-case fixes
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
