From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] lan78xx: Fix Smatch Warnings
Date: Wed, 12 Aug 2015 14:44:40 -0700 (PDT)
Message-ID: <20150812.144440.2233159331458636622.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D53FAEF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbHLVom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:44:42 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D53FAEF@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Tue, 11 Aug 2015 15:21:41 +0000

> lan78xx.c:2282 tx_complete() warn: variable dereferenced before check 'skb' (see line 2249)
> lan78xx.c:2885 lan78xx_bh() info: ignoring unreachable code.
> lan78xx.c:3159 lan78xx_probe() info: ignoring unreachable code.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied.
