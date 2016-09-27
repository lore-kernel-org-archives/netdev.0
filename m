From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH trival -resend 2/2] lib: clean up put_cpu_var usage
Date: Wed, 28 Sep 2016 01:16:14 +0200
Message-ID: <20160927231614.GC16429@mtj.duckdns.org>
References: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
 <935eea817a8d13d9223e09b4ca11e0508aee8437.1474990741.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>, akpm@linux-foundation.org
To: Shaohua Li <shli@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <935eea817a8d13d9223e09b4ca11e0508aee8437.1474990741.git.shli@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 08:42:42AM -0700, Shaohua Li wrote:
> put_cpu_var takes the percpu data, not the data returned from
> get_cpu_var.
> 
> This doesn't change the behavior.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
