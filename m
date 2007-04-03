From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] AF_RXRPC: Move generic skbuff stuff from XFRM code
 to generic code
Date: Mon, 02 Apr 2007 20:20:14 -0700 (PDT)
Message-ID: <20070402.202014.11599182.davem@davemloft.net>
References: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
	<20070402224503.31568.1112.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbXDCDUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 23:20:16 -0400
In-Reply-To: <20070402224503.31568.1112.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 02 Apr 2007 23:45:03 +0100

> Move generic skbuff stuff from XFRM code to generic code so that AF_RXRPC can
> use it too.
> 
> The kdoc comments I've attached to the functions needs to be checked by whoever
> wrote them as I had to make some guesses about the workings of these functions.
> 
> Signed-Off-By: David Howells <dhowells@redhat.com>

Patch applied to net-2.6.22, thanks a lot David.
