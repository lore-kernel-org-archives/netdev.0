From: David Miller <davem@davemloft.net>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 14:59:15 -0700 (PDT)
Message-ID: <20090925.145915.68839478.davem@davemloft.net>
References: <20090925214505.GA3472@gondor.apana.org.au>
	<4ABD3B34.8010903@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33378
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752541AbZIYV64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 17:58:56 -0400
In-Reply-To: <4ABD3B34.8010903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 25 Sep 2009 14:50:44 -0700

> I get aggregate 18Gbps with LRO v/s 12Gbps without, so it's very
> much a useful feature for me.

And it'll stay like that until you work with Herbert to fix
that performance difference.
