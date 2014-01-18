From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/41] net: Replace get_cpu_var through this_cpu_ptr
Date: Fri, 17 Jan 2014 19:05:28 -0800 (PST)
Message-ID: <20140117.190528.1133148899287145373.davem@davemloft.net>
References: <20140117151812.770437629@linux.com>
	<20140117151836.883704411@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, akpm@linuxfoundation.org, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, mingo@kernel.org,
	peterz@infradead.org, tglx@linutronix.de, netdev@vger.kernel.org,
	edumazet@google.com
To: cl@linux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140117151836.883704411@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <cl@linux.com>
Date: Fri, 17 Jan 2014 09:18:36 -0600

> [Patch depends on another patch in this series that introduces raw_cpu_ops]
> 
> Replace uses of get_cpu_var for address calculation through this_cpu_ptr.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David S. Miller <davem@davemloft.net>
