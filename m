From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] RxRPC: 2nd rewrite part 1
Date: Mon, 11 Apr 2016 15:35:11 -0400 (EDT)
Message-ID: <20160411.153511.1531573815825221764.davem@davemloft.net>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 07 Apr 2016 17:22:56 +0100

> Okay, I'm in the process of rewriting the RxRPC rewrite.  The primary aim of
> this second rewrite is to strictly control the number of active connections we
> know about and to get rid of connections we don't need much more quickly.
> 
> On top of this, there are fixes to the protocol handling which will all occur
> in later parts.

Series applied, but I had to fix up some trailing whitespace (reported by GIT)
by hand.

Thanks.
