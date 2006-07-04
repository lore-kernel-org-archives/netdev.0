From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipvs: Add sysctl documentation
Date: Mon, 03 Jul 2006 19:36:47 -0700 (PDT)
Message-ID: <20060703.193647.08322498.davem@davemloft.net>
References: <20060630061940.GA31956@verge.net.au>
	<20060630.142045.106433722.davem@davemloft.net>
	<20060703023128.GA27424@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52432
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751376AbWGDCge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:36:34 -0400
To: horms@verge.net.au
In-Reply-To: <20060703023128.GA27424@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Horms <horms@verge.net.au>
Date: Mon, 3 Jul 2006 11:31:30 +0900

> * Derived from http://www.linuxvirtualserver.org/docs/sysctl.html, v1.4
>   maintained by Wensong Zhang
> 
> * Adjusted preample to match ip-sysctl.txt
> 
> * Sorted options into alphabetical order
> 
> * Added expire_quiescent_template
> 
> * Removed timeout_* which are no longer present
> 
> * Incoporated doc/debug-levels.txt from IPVS source tree into
>   description of ipvs_debug
> 
> * Minor spelling fixes
> 
> * Further editing more than welcome
> 
> Signed-Off-By: Horms <horms@verge.net.au>

Applied, thanks Simon.

> * DaveM, do you need a 2.4 version of this document,
>   it will likely be a slightly different list of options?

I don't think it's really worthwhile, we should be touching 2.4.x
as little as possible at this point.  Changes we make in 2.4.x
should be in the "absolutely necssary" category.

