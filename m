From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 19:11:43 -0800
Message-ID: <1266462703.8446.237.camel@Joe-Laptop.home>
References: <1266458370.5719.43.camel@obelisk.thedillows.org>
	 <1266459504.8446.201.camel@Joe-Laptop.home>
	 <1266460221.5719.60.camel@obelisk.thedillows.org>
	 <20100217.184100.232538560.davem@davemloft.net>
	 <1266462064.5719.78.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266462064.5719.78.camel@obelisk.thedillows.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-02-17 at 22:01 -0500, David Dillow wrote:
> I'm don't see how dropping the typhoon patch slows Joe down, so
> I'd like to avoid having to fix things up after the fact.

I think that all of these can use netdev_<level>.

Also, these patches are trivial and can be
applied at leisure.

I do them with the long-term goal of creating
consistent kernel logging mechanisms.

Might take decades.

Anyway, if it's applied now, it can be cleaned
up as you like eventually.  Certainly it'd be
done before 2.6.34 is released in a few months.

cheers, Joe
