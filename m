From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] pktgen: Use seq_puts() where seq_printf()
 is not needed
Date: Fri, 16 May 2014 17:30:46 -0400 (EDT)
Message-ID: <20140516.173046.2199112514413631734.davem@davemloft.net>
References: <a172d598d41775093c69350f8dce4cf2a1329871.1400275290.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755991AbaEPVas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 17:30:48 -0400
In-Reply-To: <a172d598d41775093c69350f8dce4cf2a1329871.1400275290.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 16 May 2014 23:28:54 +0200

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> v2: patch was previously based on
>     ''pktgen: Add NOINIT option to leave packet data uninitialized'',
>     rebased to net-next

Applied, thanks for fixing this so quickly.
