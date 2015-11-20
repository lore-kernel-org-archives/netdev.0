From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] tcp: fix Fast Open snmp over-counting bug
Date: Fri, 20 Nov 2015 10:52:35 -0500 (EST)
Message-ID: <20151120.105235.243328989210948254.davem@davemloft.net>
References: <1447899451-24584-1-git-send-email-ycheng@google.com>
	<1447899451-24584-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759905AbbKTPwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 10:52:37 -0500
In-Reply-To: <1447899451-24584-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 18 Nov 2015 18:17:31 -0800

> Fix incrementing TCPFastOpenActiveFailed snmp stats multiple times
> when the handshake experiences multiple SYN timeouts.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
