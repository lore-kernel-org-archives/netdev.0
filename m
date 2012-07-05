From: David Miller <davem@davemloft.net>
Subject: Re: TCP transmit performance regression
Date: Thu, 05 Jul 2012 03:02:23 -0700 (PDT)
Message-ID: <20120705.030223.1974303916133819272.davem@davemloft.net>
References: <1341477192.2583.3415.camel@edumazet-glaptop>
	<CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	<1341481760.2583.3579.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom.leiming@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55031 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab2GEKCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 06:02:24 -0400
In-Reply-To: <1341481760.2583.3579.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jul 2012 11:49:20 +0200

> -			ax_skb->data = packet;

That's really scary.
