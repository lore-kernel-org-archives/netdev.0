From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: add more const attributes
Date: Mon, 24 Oct 2011 02:51:07 -0400 (EDT)
Message-ID: <20111024.025107.1158001830328808357.davem@davemloft.net>
References: <1319438111.2517.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947Ab1JXGvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 02:51:11 -0400
In-Reply-To: <1319438111.2517.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Oct 2011 08:35:11 +0200

> Now tcp_md5_hash_header() has a const tcphdr argument, we can add more
> const attributes to callers.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
