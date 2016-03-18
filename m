From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan: propagate gso_max_segs
Date: Thu, 17 Mar 2016 21:05:34 -0400 (EDT)
Message-ID: <20160317.210534.970974260375090739.davem@davemloft.net>
References: <1458190789.7353.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbcCRBFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 21:05:36 -0400
In-Reply-To: <1458190789.7353.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Mar 2016 21:59:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> vlan drivers lack proper propagation of gso_max_segs from
> lower device.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
