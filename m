From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/9] bonding: lockdep annotation
Date: Thu, 09 Nov 2006 16:05:10 -0800 (PST)
Message-ID: <20061109.160510.109055404.davem@davemloft.net>
References: <200611090351.kA93p1Kx003677@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a.p.zijlstra@chello.nl, mingo@elte.hu,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3979
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424259AbWKJAFC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 19:05:02 -0500
To: akpm@osdl.org
In-Reply-To: <200611090351.kA93p1Kx003677@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Wed, 08 Nov 2006 19:51:01 -0800

> The bonding driver nests other drivers, give the bonding driver its own
> lock class.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Ingo Molnar <mingo@elte.hu>
> Cc: Stephen Hemminger <shemminger@osdl.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks Peter.
