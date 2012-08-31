From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cs89x0 : packet reception not working
Date: Fri, 31 Aug 2012 15:49:31 -0400 (EDT)
Message-ID: <20120831.154931.1463711821590835826.davem@davemloft.net>
References: <1346104431-3784-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, s.hauer@pengutronix.de, festevam@gmail.com
To: jaccon.bastiaansen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786Ab2HaTte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 15:49:34 -0400
In-Reply-To: <1346104431-3784-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Date: Mon, 27 Aug 2012 23:53:51 +0200

> The RxCFG register of the CS89x0 could be configured incorrectly
> (because of misplaced parentheses), resulting in the disabling
> of packet reception.
> 
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>

Applied and queued up for -stable, thanks.
