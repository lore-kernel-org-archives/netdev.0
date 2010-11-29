From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 0/4] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 17:09:19 +0100
Message-ID: <20101129160919.GB15763@basil.fritz.box>
References: <1290972833.29196.90.camel@edumazet-laptop>
 <20101128224024.GA12300@basil.fritz.box>
 <1290984712.29196.100.camel@edumazet-laptop>
 <20101128230146.GB12300@basil.fritz.box>
 <1290987424.29196.128.camel@edumazet-laptop>
 <20101129090510.GA15763@basil.fritz.box>
 <1291023532.3435.29.camel@edumazet-laptop>
 <1291043604.3435.969.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291043604.3435.969.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2010 at 04:13:23PM +0100, Eric Dumazet wrote:
> Note : compiled and tested on x86_32 and x86_64 only, but these patches
> take care of other arches as well.
> 
> Cc: linux-arch@vger.kernel.org 
> 
> Thanks for your feedback Andi !

Looks good to me now. You can add

Reviewed-by: Andi Kleen <ak@linux.intel.com>

to the four patches.
-Andi
