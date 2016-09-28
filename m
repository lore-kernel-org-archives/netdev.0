From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH trival -resend 2/2] lib: clean up put_cpu_var usage
Date: Tue, 27 Sep 2016 22:10:37 -0400 (EDT)
Message-ID: <20160927.221037.170454610655198105.davem@davemloft.net>
References: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
        <935eea817a8d13d9223e09b4ca11e0508aee8437.1474990741.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        akpm@linux-foundation.org, tj@kernel.org
To: shli@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <935eea817a8d13d9223e09b4ca11e0508aee8437.1474990741.git.shli@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaohua Li <shli@fb.com>
Date: Tue, 27 Sep 2016 08:42:42 -0700

> put_cpu_var takes the percpu data, not the data returned from
> get_cpu_var.
> 
> This doesn't change the behavior.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Applied.
