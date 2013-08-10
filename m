From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 v2] drivers/net: enic: Adding support for Cisco Low
 Latency NIC
Date: Fri, 09 Aug 2013 17:51:48 -0700 (PDT)
Message-ID: <20130809.175148.2050812889880484639.davem@davemloft.net>
References: <1376073939.2087.146.camel@joe-AO722>
	<1376085623-21630-1-git-send-email-neepatel@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: neepatel@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968075Ab3HJAvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 20:51:50 -0400
In-Reply-To: <1376085623-21630-1-git-send-email-neepatel@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neel Patel <neepatel@cisco.com>
Date: Fri,  9 Aug 2013 15:00:23 -0700

> This patch,
> 	- Adds new firmware commands for the new Cisco Low Latency NIC
>       (aka. USNIC).
>     - Enables descriptor prefetch on the hardware. This feature
>       reduces latency for small packet transmit.
> 
> Signed-off-by: Neel Patel <neepatel@cisco.com>
> Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>

Please resend the whole patch series, not just the patches that
changed, when you have to change things.
