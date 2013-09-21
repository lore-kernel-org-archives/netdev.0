From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tg3: Misc cleanups and fixes.
Date: Sat, 21 Sep 2013 14:05:15 -0400 (EDT)
Message-ID: <20130921.140515.342897325124711405.davem@davemloft.net>
References: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391Ab3IUSFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:05:16 -0400
In-Reply-To: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Fri, 20 Sep 2013 16:46:54 -0700

> Nithin Nayak Sujir (8):
>   tg3: Add function tg3_phy_shdw_write()
>   tg3: Add support for new 577xx device ids
>   tg3: LED in shared mode does not blink during traffic
>   tg3: Remove if 0'd code
>   tg3: Remove redundant if check
>   tg3: Appropriately classify interrupts during request_irq
>   tg3: Remove unnecessary spinlock
>   tg3: Update version to 3.134

All applied, thanks.
