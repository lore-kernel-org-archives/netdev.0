From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] seqlock: get rid of SEQLOCK_UNLOCKED
Date: Tue, 24 May 2011 15:40:33 -0400 (EDT)
Message-ID: <20110524.154033.97802937258958106.davem@davemloft.net>
References: <1306238888.3026.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tglx@linutronix.de
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306238888.3026.31.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 May 2011 14:08:08 +0200

> All static seqlock should be initialized with the lockdep friendly
> __SEQLOCK_UNLOCKED() macro.
> 
> Remove legacy SEQLOCK_UNLOCKED() macro.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: David S. Miller <davem@davemloft.net>
