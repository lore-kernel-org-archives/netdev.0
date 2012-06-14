From: David Miller <davem@davemloft.net>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 03:31:53 -0700 (PDT)
Message-ID: <20120614.033153.258221733380821664.davem@davemloft.net>
References: <1339667417.22704.707.camel@edumazet-glaptop>
	<20120614.030021.2291563831943273331.davem@davemloft.net>
	<1339668471.22704.714.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhautbois@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450Ab2FNKb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 06:31:56 -0400
In-Reply-To: <1339668471.22704.714.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Jun 2012 12:07:51 +0200

> We should have a way to properly park packets in Qdiscs, and only do the
> orphaning once skb given to real device for 'immediate or so'
> transmission.

Ok.
