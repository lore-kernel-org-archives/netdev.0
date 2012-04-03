From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lpc_eth: no need to reserve 8 extra bytes in rx
 skb
Date: Tue, 03 Apr 2012 18:58:13 -0400 (EDT)
Message-ID: <20120403.185813.669644861254543793.davem@davemloft.net>
References: <1333490531.18626.336.camel@edumazet-glaptop>
	<4F7B7F9B.3050503@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: stigge@antcom.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab2DCW7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:59:19 -0400
In-Reply-To: <4F7B7F9B.3050503@antcom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Stigge <stigge@antcom.de>
Date: Wed, 04 Apr 2012 00:54:19 +0200

> Why add curly braces around a single statement?

Because that's how we roll for else statements homie, see CodingStyle
