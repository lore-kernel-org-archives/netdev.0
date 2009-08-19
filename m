From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Tue, 18 Aug 2009 20:34:54 -0700 (PDT)
Message-ID: <20090818.203454.222985629.davem@davemloft.net>
References: <20090705033408.GB7430@gondor.apana.org.au>
	<20090817.184712.180559154.davem@davemloft.net>
	<20090819031926.GA17367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, patrick.ohly@intel.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	divy@chelsio.com, rolandd@cisco.com, xemul@openvz.org,
	dcbw@redhat.com, libertas-dev@lists.infradead.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44054
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750769AbZHSDen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 23:34:43 -0400
In-Reply-To: <20090819031926.GA17367@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 19 Aug 2009 13:19:26 +1000

> I'm in the process of repeating the same experiment with cxgb3
> which hopefully should let me turn interrupts off on descriptors
> while still reporting completion status.

Ok, I look forward to seeing your work however it turns out.

Once I see what you've done, I'll give it a spin on niu.
