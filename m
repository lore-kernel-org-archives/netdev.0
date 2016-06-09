From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V2] net: ipconfig: add declaration for ic_addrservaddr
Date: Thu, 09 Jun 2016 13:35:35 -0700 (PDT)
Message-ID: <20160609.133535.1784019078497827547.davem@davemloft.net>
References: <1465494877-10552-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcFIUfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 16:35:37 -0400
In-Reply-To: <1465494877-10552-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Thu,  9 Jun 2016 18:54:37 +0100

> The symbol ic_addrservaddr is not static, but has no declaration
> to match so make it static to fix the following warning:
> 
> net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not declared. Should it be static?
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Your Subject line needs to be updated, you're not ading a declaration
any more.
