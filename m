From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: Disable device in error path
Date: Wed, 19 Mar 2014 16:08:55 -0400 (EDT)
Message-ID: <20140319.160855.945334873593529054.davem@davemloft.net>
References: <20140318171401.GA1184@hellgate.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, liuhq11@mails.tsinghua.edu.cn
To: rl@hellgate.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaCSUI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 16:08:56 -0400
In-Reply-To: <20140318171401.GA1184@hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roger Luethi <rl@hellgate.ch>
Date: Tue, 18 Mar 2014 18:14:01 +0100

> Currently, via-rhine fails to call pci_disable_device() for errors
> in rhine_init_one().
> 
> Reported-by: Huqiu Liu <liuhq11@mails.tsinghua.edu.cn>
> Signed-off-by: Roger Luethi <rl@hellgate.ch>

Applied, thank you.
