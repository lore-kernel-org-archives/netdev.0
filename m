From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [held lock freed] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 17:15:28 +0100
Message-ID: <20110321161528.GA28580@elte.hu>
References: <20110320.195156.226769634.davem@davemloft.net>
 <20110321125320.GA23490@elte.hu>
 <1300714346.2884.284.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300714346.2884.284.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Here is a probable fix.
> 
> [PATCH] ipx: fix ipx_release()

This patch did the trick - thanks Eric!

Tested-by: Ingo Molnar <mingo@elte.hu>

	Ingo
