From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/30] hamradio: 6pack: semaphore cleanup
Date: Tue, 07 Sep 2010 09:28:39 -0700 (PDT)
Message-ID: <20100907.092839.226767808.davem@davemloft.net>
References: <20100907124636.880953480@linutronix.de>
	<20100907125055.269142443@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	mingo@elte.hu, peterz@infradead.org, hch@infradead.org,
	netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100907125055.269142443@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 07 Sep 2010 14:32:14 -0000

> Get rid of init_MUTEX[_LOCKED]() and use sema_init() instead.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Acked-by: David S. Miller <davem@davemloft.net>
