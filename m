From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig (v2)
Date: Tue, 19 Sep 2006 14:20:07 -0700 (PDT)
Message-ID: <20060919.142007.06541289.davem@davemloft.net>
References: <20060918214104.3824a2e2@localhost.localdomain>
	<20060919.123352.124082859.davem@davemloft.net>
	<20060919134132.44d4da5d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37797
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751152AbWISVUC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 17:20:02 -0400
To: shemminger@osdl.org
In-Reply-To: <20060919134132.44d4da5d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 19 Sep 2006 13:41:32 -0700

> Bert's attempt was noble
> It showed your desire for the truth
> A simple path existed
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, but...

net/ipv4/Kconfig:607:warning: defaults for choice values not supported

Hmmm...
