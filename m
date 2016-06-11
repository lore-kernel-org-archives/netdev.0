From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V2] net: diag: add missing declarations
Date: Fri, 10 Jun 2016 23:23:09 -0700 (PDT)
Message-ID: <20160610.232309.1888176509428411521.davem@davemloft.net>
References: <1465491909-27878-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbcFKGXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:23:11 -0400
In-Reply-To: <1465491909-27878-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Thu,  9 Jun 2016 18:05:09 +0100

> The functions inet_diag_msg_common_fill and inet_diag_msg_attrs_fill
> seem to have been missed from the include/linux/inet_diag.h header
> file. Add them to fix the following warnings:
> 
> net/ipv4/inet_diag.c:69:6: warning: symbol 'inet_diag_msg_common_fill' was not declared. Should it be static?
> net/ipv4/inet_diag.c:108:5: warning: symbol 'inet_diag_msg_attrs_fill' was not declared. Should it be static?
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Applied, thanks.
