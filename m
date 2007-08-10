From: David Miller <davem@davemloft.net>
Subject: Re: [patch 13/28] fib_trie: macro cleanup
Date: Fri, 10 Aug 2007 15:23:12 -0700 (PDT)
Message-ID: <20070810.152312.101870494.davem@davemloft.net>
References: <200708102111.l7ALBv6F009410@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbXHJWXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:23:12 -0400
In-Reply-To: <200708102111.l7ALBv6F009410@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:11:57 -0700

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> This patch converts the messy macro for MASK_PFX to inline function
> and expands TKEY_GET_MASK in the one place it is used.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.24, thanks!
