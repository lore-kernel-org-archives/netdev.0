From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth-next 2014-12-31
Date: Fri, 02 Jan 2015 16:04:49 -0500 (EST)
Message-ID: <20150102.160449.1604112925381488247.davem@davemloft.net>
References: <20141231072549.GA11458@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141231072549.GA11458-ae+CCJ+dGXjCW7GOcxkI+ioyn5ZhHHrn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 31 Dec 2014 09:25:49 +0200

> Here's the first batch of bluetooth patches for 3.20.
> 
>  - Cleanups & fixes to ieee802154  drivers
>  - Fix synchronization of mgmt commands with respective HCI commands
>  - Add self-tests for LE pairing crypto functionality
>  - Remove 'BlueFritz!' specific handling from core using a new quirk flag
>  - Public address configuration support for ath3012
>  - Refactor debugfs support into a dedicated file
>  - Initial support for LE Data Length Extension feature from Bluetooth 4.2
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
