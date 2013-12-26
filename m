From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hhf: make qdisc ops static
Date: Thu, 26 Dec 2013 13:30:17 -0500 (EST)
Message-ID: <20131226.133017.1789852303815779564.davem@davemloft.net>
References: <20131226100905.00ac74a2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vtlam@google.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab3LZSaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:30:19 -0500
In-Reply-To: <20131226100905.00ac74a2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 26 Dec 2013 10:09:05 -0800

> This module shouldn't be randomly exporting symbols 
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
