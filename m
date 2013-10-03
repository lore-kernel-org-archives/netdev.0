From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 3com: Fix drivers/net/ethernet/3com/Kconfig
 references to PCMCIA and 3c515
Date: Thu, 03 Oct 2013 15:55:47 -0400 (EDT)
Message-ID: <20131003.155547.1184801461974488959.davem@davemloft.net>
References: <1380726483-17247-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370Ab3JCTzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:55:49 -0400
In-Reply-To: <1380726483-17247-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Wed,  2 Oct 2013 11:08:03 -0400

> The Vortex driver works with PCI and Cardbus devices, not PCMCIA.
> 
> There never was an EISA 3c515 card, only ISA, so remove that option.
> 
> Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>

Applied, thank you.
