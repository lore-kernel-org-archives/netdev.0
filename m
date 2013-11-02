From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/7] smsc: replace printk with netdev_ calls
Date: Sat, 02 Nov 2013 01:21:21 -0400 (EDT)
Message-ID: <20131102.012121.334811730274714188.davem@davemloft.net>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
	<1383310416-27177-1-git-send-email-mathstuf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mathstuf@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab3KBFVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 01:21:22 -0400
In-Reply-To: <1383310416-27177-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Boeckel <mathstuf@gmail.com>
Date: Fri,  1 Nov 2013 08:53:29 -0400

> Clean up printk calls in smsc network drivers by using netdev_<level>
> instead. Also fixes some whitespace errors (trailing whitespace,
> spaces-between-tabs) noticed while fixing the printk calls. Reindenting files
> was not done.
> 
> I've compile tested them all on x86 by forcing them to at least compile to
> catch obvious errors.

Applied, thanks Ben.
