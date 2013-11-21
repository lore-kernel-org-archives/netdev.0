From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Thu, 21 Nov 2013 13:35:01 -0500 (EST)
Message-ID: <20131121.133501.272071098922555423.davem@davemloft.net>
References: <5286F018.8060801@gmail.com>
	<20131116064611.GA12146@gondor.apana.org.au>
	<528A51B6.2040609@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, alexander.duyck@gmail.com,
	netdev@vger.kernel.org, edumazet@google.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab3KUSfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:35:03 -0500
In-Reply-To: <528A51B6.2040609@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 18 Nov 2013 09:43:18 -0800

> I'm not going to have a chance to test this today, but on review it
> should fix the issue.
> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

I've lost track of this dicussion, Herbert could you post the patches
I should apply?  I think it was this one and a follow-on simplification
to the checksum handling?

Thanks.
