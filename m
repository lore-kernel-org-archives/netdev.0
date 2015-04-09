From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth-next 2015-04-09
Date: Thu, 09 Apr 2015 18:32:16 -0400 (EDT)
Message-ID: <20150409.183216.859661318603982114.davem@davemloft.net>
References: <20150409195850.GA23404@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150409195850.GA23404-ae+CCJ+dGXjCW7GOcxkI+ioyn5ZhHHrn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 9 Apr 2015 22:58:50 +0300

> We've had enough new patches during the past week (especially from
> Marcel) that it'd be good to still get these queued for 4.1.
> 
> The majority of the changes are from Marcel with lots of cleanup &
> refactoring patches for the HCI UART driver. Marcel also split out some
> Broadcom & Intel vendor specific functionality into two new btintel &
> btbcm modules.
> 
> In addition to the HCI driver changes there's the completion of our
> local OOB data interface for pairing, added support for requesting
> remote LE features when connecting, as well as a couple of minor fixes
> for mac802154.
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
