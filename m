From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fib_rules: add route suppression based on ifgroup
Date: Fri, 02 Aug 2013 15:24:57 -0700 (PDT)
Message-ID: <20130802.152457.2096924772877120236.davem@davemloft.net>
References: <20130802151956.GK21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefan.tomanek@wertarbyte.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab3HBWY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:24:58 -0400
In-Reply-To: <20130802151956.GK21970@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Date: Fri, 2 Aug 2013 17:19:56 +0200

> This change adds the ability to suppress a routing decision based upon the
> interface group the selected interface belongs to. This allows it to
> exclude specific devices from a routing decision.
> 
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>

Looks fine, applied, thanks.
