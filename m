From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rxrpc: Check allocation failure.
Date: Mon, 22 Mar 2010 10:23:08 -0700 (PDT)
Message-ID: <20100322.102308.62362847.davem@davemloft.net>
References: <20100322135019.15704.20997.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755068Ab0CVRWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 13:22:45 -0400
In-Reply-To: <20100322135019.15704.20997.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Mon, 22 Mar 2010 13:50:19 +0000

> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> alloc_skb() can return NULL.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks guys.
