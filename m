From: David Miller <davem@davemloft.net>
Subject: Re: |PATCH net-next] tg3: add tx_dropped counter
Date: Mon, 24 Oct 2011 18:35:56 -0400 (EDT)
Message-ID: <20111024.183556.175862455915569616.davem@davemloft.net>
References: <1319478783.3064.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725Ab1JXWgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 18:36:01 -0400
In-Reply-To: <1319478783.3064.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Oct 2011 19:53:03 +0200

> If a frame cant be transmitted, it is silently discarded.
> 
> Add a counter to report these errors to user.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
