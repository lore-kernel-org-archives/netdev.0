From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: fix build warnings with CONFIG_PM_SLEEP
 disabled
Date: Mon, 14 Mar 2011 14:26:39 -0700 (PDT)
Message-ID: <20110314.142639.102555050.davem@davemloft.net>
References: <20110307021450.GC31188@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: walken@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110307021450.GC31188@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michel Lespinasse <walken@google.com>
Date: Sun, 6 Mar 2011 18:14:50 -0800

> This fixes a couple of build warnings when CONFIG_PM is enabled but
> CONFIG_PM_SLEEP is disabled. Applies on top of v2.6.38-rc7 - I know it's
> late, but it would be great if v2.6.38 could compile without warnings!
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

I know it'd "be great" if this went into 2.6.38 but it doesn't fix
any real bugs, so I'm putting it into net-next-2.6

Thanks.
