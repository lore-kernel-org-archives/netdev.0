From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 23:17:05 -0700 (PDT)
Message-ID: <20060426.231705.67148890.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
	<1146109226.11864.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, kelly@au1.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41886
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964955AbWD0GRV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 02:17:21 -0400
To: rusty@rustcorp.com.au
In-Reply-To: <1146109226.11864.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 27 Apr 2006 13:40:26 +1000

> We *used* to have an nf_cache mechanism to determine exactly when the
> netfilter hooks cared about a packet, but it was never used and was hard
> to reconcile with connection-tracking timeouts...

Let's not consider bringing that thing back :-)
