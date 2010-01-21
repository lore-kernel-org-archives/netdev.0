From: David Miller <davem@davemloft.net>
Subject: Re: net: [PATCH] Optimize non-gso test checks
Date: Thu, 21 Jan 2010 01:26:41 -0800 (PST)
Message-ID: <20100121.012641.08658811.davem@davemloft.net>
References: <20100120123033.28183.78883.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754795Ab0AUJ0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 04:26:30 -0500
In-Reply-To: <20100120123033.28183.78883.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 20 Jan 2010 18:00:33 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Avoid checking twice whether skb needs to be linearized, if one
> skb_linearize was already done.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied to net-next-2.6, thanks.
