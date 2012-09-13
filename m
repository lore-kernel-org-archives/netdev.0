From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv6: Add labels for site-local and 6bone testing
 addresses (RFC6724)
Date: Thu, 13 Sep 2012 16:34:48 -0400 (EDT)
Message-ID: <20120913.163448.1382033032653313839.davem@davemloft.net>
References: <201209110508.q8B58GJO015601@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257Ab2IMUeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:34:50 -0400
In-Reply-To: <201209110508.q8B58GJO015601@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 11 Sep 2012 13:16:49 +0900

> Added labels for site-local addresses (fec0::/10) and 6bone testing
> addresses (3ffe::/16) in order to depreference them.
> 
> Note that the RFC introduced new rows for Teredo, ULA and 6to4 addresses
> in the default policy table.  Some of them have different labels from ours.
> For backward compatibility, we do not change the "default" labels.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-next.
