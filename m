From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: fec: add new type device
Date: Mon, 27 Jun 2016 04:02:50 -0400 (EDT)
Message-ID: <20160627.040250.2095830432996906213.davem@davemloft.net>
References: <1466592756-11239-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: fugang.duan@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbcF0IDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 04:03:19 -0400
In-Reply-To: <1466592756-11239-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Duan <fugang.duan@nxp.com>
Date: Wed, 22 Jun 2016 18:52:34 +0800

> Different i.MX SOC FEC support different features like :
>     - i.MX6Q/DL FEC does not support AVB and interrupt coalesc
>     - i.MX6SX/i.MX7D supports AVB and interrupt coalesc
>     - i.MX6UL/ULL does not support AVB, but support interrupt coalesc
> 
> Then, add new quirk flag to judge the supported features, and add new
> type device for i.MX6UL.

Series applied, thanks.
