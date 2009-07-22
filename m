From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] softirq: tasklet_hrtimer
Date: Wed, 22 Jul 2009 08:39:38 -0700 (PDT)
Message-ID: <20090722.083938.214269732.davem@davemloft.net>
References: <1247832892.15751.35.camel@twins>
	<20090721.201855.32703627.davem@davemloft.net>
	<1248265724.27058.1366.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: peterz@infradead.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753235AbZGVPje@vger.kernel.org>
In-Reply-To: <1248265724.27058.1366.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 22 Jul 2009 14:28:44 +0200

> Thomas, will you take this?
> 
> ---
> Subject: softirq: tasklet_hrtimer
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Wed Jul 22 14:18:35 CEST 2009
> 
> Stick tasklets and hrtimers together to provide an in-softirq hrtimer
> experience.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Acked-by: David S. Miller <davem@davemloft.net>
