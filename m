From: David Miller <davem@davemloft.net>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 06 Apr 2011 13:29:06 -0700 (PDT)
Message-ID: <20110406.132906.200378990.davem@davemloft.net>
References: <20110406195719.GE14697@ghostprotocols.net>
	<20110406.130239.232756965.davem@davemloft.net>
	<1302121136.2701.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, jesse.brandeburg@gmail.com,
	fedora-kernel-list@redhat.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755805Ab1DFU3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:29:43 -0400
In-Reply-To: <1302121136.2701.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Apr 2011 22:18:56 +0200

> I remember last time I work on a fedora kernel, it had conntrack enabled
> 
> And yes, conntrack can really slowdown a router, because of default
> parameters.

Yes, if conntrack is enabled performance will indeed tank.
