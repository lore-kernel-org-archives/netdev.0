From: David Miller <davem@davemloft.net>
Subject: Re: net-next currently not in good shape
Date: Wed, 08 May 2013 17:57:52 -0700 (PDT)
Message-ID: <20130508.175752.2155159503138170718.davem@davemloft.net>
References: <1368055825.13473.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab3EIA5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 20:57:55 -0400
In-Reply-To: <1368055825.13473.31.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 May 2013 16:30:25 -0700

> net-next is currently lacking following patch and dies at boot time (at
> leat on my machines)
> 
> This message might help others.

Ok, I plan to send Linus what's in 'net' right now (which has the
same problem) and this will all get sorted when he merges my
'net' tree and I merge back from his tree.
