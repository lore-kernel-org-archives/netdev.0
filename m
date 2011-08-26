From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] af_packet: Prefixed tpacket_v3 structs to
 avoid name space collision
Date: Fri, 26 Aug 2011 12:39:47 -0400 (EDT)
Message-ID: <20110826.123947.1236839282053031374.davem@davemloft.net>
References: <1314305010-1154-1-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311Ab1HZQjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:39:51 -0400
In-Reply-To: <1314305010-1154-1-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <loke.chetan@gmail.com>
Date: Thu, 25 Aug 2011 16:43:30 -0400

> structs introduced in tpacket_v3 implementation are prefixed with 'tpacket'
> to avoid namespace collision.
> 
> Compile tested.
> 
> Signed-off-by: Chetan Loke <loke.chetan@gmail.com>

Applied, thanks.
