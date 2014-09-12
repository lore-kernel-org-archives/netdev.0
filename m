From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] sunvnet: generate ICMP PTMUD messages for
 smaller port MTUs
Date: Fri, 12 Sep 2014 18:26:43 -0400 (EDT)
Message-ID: <20140912.182643.2267737158715012533.davem@davemloft.net>
References: <5413723C.7040607@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbaILW0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 18:26:45 -0400
In-Reply-To: <5413723C.7040607@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Fri, 12 Sep 2014 18:22:52 -0400

> +		if (skb->protocol == htons(ETH_P_IP))
> +		{

Openning braces should be on the same line as the if() statement.
