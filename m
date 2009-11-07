From: David Miller <davem@davemloft.net>
Subject: Re: [patch 03/16] net: Replace old style lock initializer
Date: Fri, 06 Nov 2009 22:17:35 -0800 (PST)
Message-ID: <20091106.221735.133841470.davem@davemloft.net>
References: <20091106223547.784916750@linutronix.de>
	<20091106223806.519088363@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, peterz@infradead.org,
	netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751044AbZKGGRL@vger.kernel.org>
In-Reply-To: <20091106223806.519088363@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 06 Nov 2009 22:41:15 -0000

> SPIN_LOCK_UNLOCKED is deprecated. Use DEFINE_SPINLOCK instead.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Applied to net-next-2.6, thanks.
