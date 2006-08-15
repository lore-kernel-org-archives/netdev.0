From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/13] xt_physdev build fix
Date: Tue, 15 Aug 2006 00:10:14 -0700 (PDT)
Message-ID: <20060815.001014.51419424.davem@davemloft.net>
References: <200608150603.k7F63eVv012939@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bdschuym@pandora.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22708
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965257AbWHOHKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:10:14 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63eVv012939@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:40 -0700

> From: Andrew Morton <akpm@osdl.org>
> 
> It needs netfilter_bridge.h for brnf_deferred_hooks
> 
> Cc: Bart De Schuymer <bdschuym@pandora.be>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Build fix, so I'll queue it up for 2.6.18
