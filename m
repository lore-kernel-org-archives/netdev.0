From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 11/31] net: Replace get_cpu_var through this_cpu_ptr
Date: Fri, 18 Jul 2014 19:29:42 -0400
Message-ID: <20140718232942.GR5739@htj.dyndns.org>
References: <20140620193115.547427118@linux.com>
 <20140620193126.160285131@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140620193126.160285131@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 20, 2014 at 02:31:26PM -0500, Christoph Lameter wrote:
> Replace uses of get_cpu_var for address calculation through this_cpu_ptr.
> 
> Cc: netdev@vger.kernel.org
> Cc: Eric Dumazet <edumazet@google.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Applied to wq/for-3.17-consistent-ops.  If this patch should be routed
differently, please holler.

Thanks.

-- 
tejun
