From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TIPC: make function tipc_nameseq_subscribe static
Date: Thu, 02 Aug 2007 19:26:46 -0700 (PDT)
Message-ID: <20070802.192646.14942685.davem@davemloft.net>
References: <20070802225638.GA14966@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, per.liden@ericsson.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33091
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751704AbXHCC0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 22:26:45 -0400
In-Reply-To: <20070802225638.GA14966@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Fri, 3 Aug 2007 00:56:38 +0200

> make needlessly global function tipc_nameseq_subscribe static.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Patch applied, thanks Florian.
