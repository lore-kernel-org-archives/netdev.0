From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove dead debug code from ip6_tunnel.c
Date: Tue, 24 Feb 2015 16:25:47 -0500 (EST)
Message-ID: <20150224.162547.1183495924194312981.davem@davemloft.net>
References: <1424779285-27177-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ipm@chirality.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51153 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943AbbBXVZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:25:49 -0500
In-Reply-To: <1424779285-27177-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>
Date: Tue, 24 Feb 2015 12:01:25 +0000

> The IP6_TNL_TRACE macro is no longer used anywhere in the code so remove definition.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>

Applied.
