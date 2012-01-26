From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Thu, 26 Jan 2012 13:51:44 -0500 (EST)
Message-ID: <20120126.135144.1300628572404824368.davem@davemloft.net>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
	<02e98f84ee62073e1bf92338f6744fde@localhost>
	<1327502660.2425.60.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, satoru.moriya@hds.com, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, tgraf@infradead.org,
	stephen.hemminger@vyatta.com, seiji.aguchi@hds.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab2AZSyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 13:54:08 -0500
In-Reply-To: <1327502660.2425.60.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2012 15:44:20 +0100

> [PATCH net-next] tcp: add LINUX_MIB_TCPRETRANSFAIL counter
> 
> It might be useful to get a counter of failed tcp_retransmit_skb()
> calls.
> 
> Reported-by: Satoru Moriya <satoru.moriya@hds.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
