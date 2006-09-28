From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/2] [IPVS]: Make sure ip_vs_ftp ports are valid (again)
Date: Wed, 27 Sep 2006 22:53:54 -0700 (PDT)
Message-ID: <20060927.225354.48396393.davem@davemloft.net>
References: <20060920144457.533479580@yukiko.lab.ultramonkey.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, wensong@linux-vs.org,
	ja@ssi.bg, jmack@wm7d.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30085
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965286AbWI1Fxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 01:53:55 -0400
To: horms@verge.net.au
In-Reply-To: <20060920144457.533479580@yukiko.lab.ultramonkey.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Horms <horms@verge.net.au>
Date: Wed, 20 Sep 2006 23:44:57 +0900

> there are two patches floating around for this problem.
> It seems that the first incarntation has been committed
> to Linus's tree as 3f5af5b353ca36aca4f8a46e3da2172f669dbbbc.
> 
> This series of 2 patches reverses that change, and
> adds the new, simpler, change in its place.

Both applied, thanks Simon.

If you think it's serious enough to submit for -stable, just
let me know.
