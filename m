From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev config: revert part of previous patch
Date: Mon, 25 Sep 2006 23:11:31 -0700 (PDT)
Message-ID: <20060925.231131.98749285.davem@davemloft.net>
References: <20060922125625.36a5c56b.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org, blaisorblade@yahoo.it,
	sam@ravnborg.org, jengelh@linux01.gwdg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30905
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751380AbWIZGL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 02:11:28 -0400
To: rdunlap@xenotime.net
In-Reply-To: <20060922125625.36a5c56b.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Fri, 22 Sep 2006 12:56:25 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Net devices should depend on NETDEVICES, so revert part of
> Paolo's previous patch.
> 
> See http://marc.theaimsgroup.com/?l=linux-kernel&m=115566326218740&w=2
> for history.
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks Randy.
