From: David Miller <davem@davemloft.net>
Subject: Re: [RTNL]: Add missing link netlink attribute policy definitions
Date: Tue, 19 Feb 2008 16:12:18 -0800 (PST)
Message-ID: <20080219.161218.28391471.davem@davemloft.net>
References: <20080219234606.GA3119@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753519AbYBTALl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 19:11:41 -0500
In-Reply-To: <20080219234606.GA3119@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 20 Feb 2008 00:46:06 +0100

> IFLA_LINK is no longer a write-only attribute on the kernel
> side and must thus be validated. Same goes for the newly
> introduced IFLA_LINKINFO.
> 
> Fixes undefined behaviour if either of the attributes are
> not well formed.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
