From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: rename tcp_skb_cb flags
Date: Tue, 27 Sep 2011 13:25:12 -0400 (EDT)
Message-ID: <20110927.132512.82015722401706058.davem@davemloft.net>
References: <1317103249.2796.25.camel@edumazet-laptop>
	<20110927.022025.1306291417181821045.davem@davemloft.net>
	<1317117114.2541.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928Ab1I0RZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 13:25:20 -0400
In-Reply-To: <1317117114.2541.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Sep 2011 11:51:54 +0200

> Rename struct tcp_skb_cb "flags" to "tcp_flags" to ease code review and
> maintenance.
> 
> Its content is a combination of FIN/SYN/RST/PSH/ACK/URG/ECE/CWR flags
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
