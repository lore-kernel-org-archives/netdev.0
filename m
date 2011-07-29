From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 07:39:10 -0700 (PDT)
Message-ID: <20110729.073910.59762029845942660.davem@davemloft.net>
References: <1311946421.2843.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4E32C302.8050304@hippy.csoma.elte.hu>
	<1311950184.2843.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: synapse@hippy.csoma.elte.hu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab1G2OjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 10:39:24 -0400
In-Reply-To: <1311950184.2843.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jul 2011 16:36:24 +0200

> Hmm, I'll take a look, but check_peer_redir() seems suspicious at first
> glance.

I take full responsibility for any bugs you discover in it :-)
