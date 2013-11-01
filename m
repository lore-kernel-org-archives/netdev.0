From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: 3.12-rc7 regression - network panic from ipv6
Date: Fri, 1 Nov 2013 08:56:15 +0100
Message-ID: <20131101075615.GK31491@secunet.com>
References: <alpine.SOC.1.00.1310292221550.19416@math.ut.ee>
 <20131029210758.GA18323@order.stressinduktion.org>
 <alpine.SOC.1.00.1310292338010.22172@math.ut.ee>
 <20131029.174258.1677867676998240250.davem@davemloft.net>
 <20131030130945.GJ31491@secunet.com>
 <alpine.SOC.1.00.1310302340170.24516@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.SOC.1.00.1310302340170.24516@math.ut.ee>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 30, 2013 at 11:41:09PM +0200, mroos@linux.ee wrote:
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Works fine, thanks!
> 
> Tested-by: Meelis Roos <mroos@linux.ee>
> 

I've applied the fix now to the ipsec tree. Again thanks for
reporting and testing!
