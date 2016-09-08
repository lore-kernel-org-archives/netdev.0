From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/1] rxrpc: Local abort tracepoint
Date: Wed, 07 Sep 2016 17:22:25 -0700 (PDT)
Message-ID: <20160907.172225.568518857497412386.davem@davemloft.net>
References: <147326192560.26960.8043603964158528938.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752661AbcIHAWk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 20:22:40 -0400
In-Reply-To: <147326192560.26960.8043603964158528938.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Wed, 07 Sep 2016 16:25:50 +0100

> 
> Here's a patch that adds a tracepoint that allows local aborts to be
> debugged.  This needs to be applied on top of the just-posted call refcount
> overhaul patch.
> 
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160904-2

Also pulled, thanks a lot David.
