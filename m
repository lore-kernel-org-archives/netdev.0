From: David Miller <davem@davemloft.net>
Subject: Re: Remove printk from rds_sendmsg
Date: Tue, 20 Mar 2012 16:12:59 -0400 (EDT)
Message-ID: <20120320.161259.1804504946572194386.davem@davemloft.net>
References: <20120319224008.GA23036@redhat.com>
	<20120319.184335.1229962428916453634.davem@davemloft.net>
	<20120319230107.GA23987@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab2CTUNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 16:13:05 -0400
In-Reply-To: <20120319230107.GA23987@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 19 Mar 2012 19:01:07 -0400

> no socket layer outputs a message for this error and neither should rds.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied and queued up for -stable, thanks.
