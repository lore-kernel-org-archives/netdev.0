From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sock.h: fix sk_peek_off kernel-doc warning
Date: Tue, 17 Apr 2012 22:39:15 -0400 (EDT)
Message-ID: <20120417.223915.1699673916322956368.davem@davemloft.net>
References: <4F8E04E9.7030607@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab2DRCjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:39:16 -0400
In-Reply-To: <4F8E04E9.7030607@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Tue, 17 Apr 2012 17:03:53 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix kernel-doc warning in net/sock.h:
> 
> Warning(include/net/sock.h:377): No description found for parameter 'sk_peek_off'
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks Randy.
