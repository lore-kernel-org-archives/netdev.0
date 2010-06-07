From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139too: fix buffer overrun in rtl8139_init_board
Date: Mon, 07 Jun 2010 01:14:08 -0700 (PDT)
Message-ID: <20100607.011408.108797895.davem@davemloft.net>
References: <20100605094549.GA11559@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: dkirjanov@hera.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753847Ab0FGIN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:13:58 -0400
In-Reply-To: <20100605094549.GA11559@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Date: Sat, 5 Jun 2010 09:45:49 +0000

> Fix rtl_chip_info buffer overrun when we can't identify the chip.
> (i = ARRAY_SIZE (rtl_chip_info) in this case)
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Applied, thanks!
