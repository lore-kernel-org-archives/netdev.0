From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: change name length
Date: Fri, 11 Aug 2006 16:42:37 -0700 (PDT)
Message-ID: <20060811.164237.29812784.davem@davemloft.net>
References: <20060811151329.3bcb94b8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8931
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751240AbWHKXmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 19:42:24 -0400
To: shemminger@osdl.org
In-Reply-To: <20060811151329.3bcb94b8@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 11 Aug 2006 15:13:29 -0700

> Some improvements to robust name interface.  These API's are safe
> now by convention, but it is worth providing some safety checks
> against future bugs.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
