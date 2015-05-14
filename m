From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] netconsole: implement extended console support
Date: Thu, 14 May 2015 11:12:41 -0400
Message-ID: <20150514151241.GH11388@htj.duckdns.org>
References: <20150511203745.GI11388@htj.duckdns.org>
 <20150512.192322.2233784105592482987.davem@davemloft.net>
 <20150513154620.GX11388@htj.duckdns.org>
 <20150514.003917.1450039994643712704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150514.003917.1450039994643712704.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, David.

On Thu, May 14, 2015 at 12:39:17AM -0400, David Miller wrote:
> Ok I'm fine with this series from my end, and you can merge this
> wherever the extended console support bits go.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Awesome, thanks.  Andrew, I think it'd be best to route this with the
extended printk patchset through -mm.  I'll repost the combined
patchset with the suggested comment added.

Thanks.

-- 
tejun
