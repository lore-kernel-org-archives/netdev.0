From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth 2015-08-11
Date: Tue, 11 Aug 2015 14:16:58 -0700 (PDT)
Message-ID: <20150811.141658.1638018493466749703.davem@davemloft.net>
References: <20150811200406.GA6173@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150811200406.GA6173-ae+CCJ+dGXjCW7GOcxkI+ioyn5ZhHHrn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 11 Aug 2015 23:04:06 +0300

> Here's an important regression fix for the 4.2-rc series that ensures
> user space isn't given invalid LTK values. The bug essentially prevents
> the encryption of subsequent LE connections, i.e. makes it impossible to
> pair devices over LE.
> 
> Let me know if there are any issues pulling. Thanks.

Pulled, thanks.
