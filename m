From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] rtnl: send notification in do_setlink()
Date: Tue, 02 Sep 2014 12:58:54 -0700 (PDT)
Message-ID: <20140902.125854.1658380924665922545.davem@davemloft.net>
References: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426AbaIBT66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 15:58:58 -0400
In-Reply-To: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon,  1 Sep 2014 16:07:25 +0200

> This serie ensures to call the notifier chain and to send a netlink message when
> a change is done by do_setlink().
> 
> The three first patches mainly prepare the last one, which do this change.

This looks fine, series applied, thanks.
