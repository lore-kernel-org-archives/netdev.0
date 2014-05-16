From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: Use seq_puts() where seq_printf() is
 not needed
Date: Fri, 16 May 2014 17:02:15 -0400 (EDT)
Message-ID: <20140516.170215.1654993200108983563.davem@davemloft.net>
References: <090215cd09d88cd79c4e37ff2cc9f7da58205f76.1400237005.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755616AbaEPVCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 17:02:16 -0400
In-Reply-To: <090215cd09d88cd79c4e37ff2cc9f7da58205f76.1400237005.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 16 May 2014 12:53:20 +0200

> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thomas, this doesn't apply cleanly to net-next, please respin.

Thank you.
