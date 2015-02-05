From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Only set has-GBP bit in header if any
 other bits would be set
Date: Thu, 05 Feb 2015 00:38:13 -0800 (PST)
Message-ID: <20150205.003813.957201457920099234.davem@davemloft.net>
References: <776a985ae0db9e2c24aefe6d7d6cef1794eb685a.1423065534.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemlof.net, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960AbbBEIiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:38:14 -0500
In-Reply-To: <776a985ae0db9e2c24aefe6d7d6cef1794eb685a.1423065534.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed,  4 Feb 2015 17:00:04 +0100

> This allows for a VXLAN-GBP socket to talk to a Linux VXLAN socket by
> not setting any of the bits.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
