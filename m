From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: systemport: log RX buffer allocation
 and RX/TX DMA failures
Date: Fri, 21 Nov 2014 14:46:31 -0500 (EST)
Message-ID: <20141121.144631.1950232704110603538.davem@davemloft.net>
References: <1416421796-27657-1-git-send-email-f.fainelli@gmail.com>
	<1416421796-27657-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342AbaKUTqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 14:46:34 -0500
In-Reply-To: <1416421796-27657-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 19 Nov 2014 10:29:55 -0800

> To help troubleshoot heavy memory pressure conditions, add a bunch of
> statistics counter to log RX buffer allocation and RX/TX DMA mapping
> failures. These are reported like any other counters through the ethtool
> stats interface.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
