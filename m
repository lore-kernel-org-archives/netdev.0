From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 9 Aug 2013 00:23:20 +0300
Message-ID: <20130808212320.GF5502@mwanda>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
 <20130808210918.GE5502@mwanda>
 <20130808.142054.1541424422807503741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kumargauravgupta3@gmail.com, emilio@elopez.com.ar,
	mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130808.142054.1541424422807503741.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 08, 2013 at 02:20:54PM -0700, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Fri, 9 Aug 2013 00:09:18 +0300
> 
> > On Fri, Aug 09, 2013 at 12:50:49AM +0530, Kumar Gaurav wrote:
> >> Removed IRQF_DISABLED as it's no-op and should be removed
> >> 
> > 
> > What?  No, that doesn't sound right.
> 
> The IRQ layer completely ignores the flag for several releases
> now, it's a complete no-op as his commit message so adequately
> states.
> 
> So what's the problem again? :-)

Ah...  Thanks for the explanation.

regards,
dan carpenter

