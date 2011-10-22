From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: add rfc 3168 extract in front of
 INET_ECN_encapsulate()
Date: Sat, 22 Oct 2011 01:26:10 -0400 (EDT)
Message-ID: <20111022.012610.326625479578659747.davem@davemloft.net>
References: <1319260268.6180.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931Ab1JVF0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 01:26:19 -0400
In-Reply-To: <1319260268.6180.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Oct 2011 07:11:08 +0200

> INET_ECN_encapsulate() is better understood if we can read the official
> statement.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
