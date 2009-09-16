From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RxRPC: Use uX/sX rather than uintX_t/intX_t types
Date: Wed, 16 Sep 2009 00:01:24 -0700 (PDT)
Message-ID: <20090916.000124.135317536.davem@davemloft.net>
References: <20090915101631.1051.70606.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@linux-foundation.org,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757018AbZIPHBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 03:01:07 -0400
In-Reply-To: <20090915101631.1051.70606.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 15 Sep 2009 11:16:31 +0100

> Use uX rather than uintX_t types for consistency.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks for fixing this up so quickly!
