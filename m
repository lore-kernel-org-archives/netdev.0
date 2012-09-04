From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: fix a lockdep splat
Date: Tue, 04 Sep 2012 14:08:22 -0400 (EDT)
Message-ID: <20120904.140822.101621228456143956.davem@davemloft.net>
References: <1346779137.13121.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757425Ab2IDSIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 14:08:24 -0400
In-Reply-To: <1346779137.13121.54.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Sep 2012 19:18:57 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Fixes following lockdep splat :
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
