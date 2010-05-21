From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: Fix memleak in sh_mdio_release
Date: Thu, 20 May 2010 23:14:00 -0700 (PDT)
Message-ID: <20100520.231400.43444964.davem@davemloft.net>
References: <20100520140059.GA8968@hera.kernel.org>
	<AANLkTikXzLHCwIFashAm1Z22Mw6n0TxC0AcBc4ER7zI6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkirjanov@hera.kernel.org, shimoda.yoshihiro@renesas.com,
	morimoto.kuninori@renesas.com, netdev@vger.kernel.org
To: iwamatsu@nigauri.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933241Ab0EUGNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 02:13:51 -0400
In-Reply-To: <AANLkTikXzLHCwIFashAm1Z22Mw6n0TxC0AcBc4ER7zI6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Date: Fri, 21 May 2010 07:12:21 +0900

> 2010/5/20 Denis Kirjanov <dkirjanov@hera.kernel.org>:
>> Allocated memory for IRQs should be freed when releasing the mii_bus
>>
>> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
...
> Acked-by: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>

Applied, thanks everyone.
