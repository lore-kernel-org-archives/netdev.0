From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/9] bonding: lockdep annotation
Date: Fri, 10 Nov 2006 12:45:56 -0800 (PST)
Message-ID: <20061110.124556.130237858.davem@davemloft.net>
References: <200611090351.kA93p1Kx003677@shell0.pdx.osdl.net>
	<4554A435.5070500@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, a.p.zijlstra@chello.nl,
	mingo@elte.hu, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50824
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424414AbWKJUp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 15:45:56 -0500
To: jeff@garzik.org
In-Reply-To: <4554A435.5070500@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 10 Nov 2006 11:09:25 -0500

> akpm@osdl.org wrote:
> > From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > 
> > =============================================
> > [ INFO: possible recursive locking detected ]
> > 2.6.17-1.2600.fc6 #1
> > ---------------------------------------------
> 
> applied; please CC me on this drivers/net stuff

Jeff, I put this one in my net-2.6.20 tree already.

