From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/41] net: Replace __this_cpu_inc in route.c with
 raw_cpu_inc
Date: Fri, 17 Jan 2014 19:05:21 -0800 (PST)
Message-ID: <20140117.190521.915406120394092952.davem@davemloft.net>
References: <20140117151812.770437629@linux.com>
	<20140117151836.140608046@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, akpm@linuxfoundation.org, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, mingo@kernel.org,
	peterz@infradead.org, tglx@linutronix.de, netdev@vger.kernel.org,
	edumazet@google.com
To: cl@linux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140117151836.140608046@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <cl@linux.com>
Date: Fri, 17 Jan 2014 09:18:29 -0600

> Acked-by: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David S. Miller <davem@davemloft.net>
