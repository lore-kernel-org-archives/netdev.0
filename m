From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 04:08:53 -0400 (EDT)
Message-ID: <20110927.040853.516739403765881835.davem@davemloft.net>
References: <1317103249.2796.25.camel@edumazet-laptop>
	<20110927.022025.1306291417181821045.davem@davemloft.net>
	<201109271037.38786.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hkchu@google.com,
	ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab1I0IKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 04:10:17 -0400
In-Reply-To: <201109271037.38786.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Tue, 27 Sep 2011 10:37:38 +0300

> However, (as far as I can see) before Eric's change it was 42 bytes long and 
> now it became 43 bytes.

Then, I suggest that you go buy a pair of glasses. :-)
