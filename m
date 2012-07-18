From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/15] ipv4: Cache output routes in fib_info nexthops.
Date: Wed, 18 Jul 2012 13:49:44 -0700 (PDT)
Message-ID: <20120718.134944.1556490195867452914.davem@davemloft.net>
References: <1342643659.2626.3636.camel@edumazet-glaptop>
	<20120718.133647.1948216070418950586.davem@davemloft.net>
	<1342644032.2626.3651.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362Ab2GRUtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:49:45 -0400
In-Reply-To: <1342644032.2626.3651.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 22:40:32 +0200

> On Wed, 2012-07-18 at 13:36 -0700, David Miller wrote:
> 
>> Do you really think it's faster/better in this case?  I did consider
>> it.
> 
> No, but code is smaller ;)

Ok, I'm convinced :)
