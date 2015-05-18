From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/net: expect headroom in
 psock_fanout rollover
Date: Mon, 18 May 2015 17:04:59 -0400 (EDT)
Message-ID: <20150518.170459.1545349559018472418.davem@davemloft.net>
References: <1431978131-30579-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbbERVFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 17:05:01 -0400
In-Reply-To: <1431978131-30579-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon, 18 May 2015 15:42:11 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> psock_fanout tests the various fanout modes. Change the test for
> rollover mode to expect early rollover due to socket pressure
> as implemented in 2ccdbaa6d55b ("packet: rollover lock contention
> avoidance").
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.
