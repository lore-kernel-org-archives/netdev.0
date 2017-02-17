From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: Change module filename to rxrpc.ko
Date: Fri, 17 Feb 2017 15:09:42 -0500 (EST)
Message-ID: <20170217.150942.1854100630890347821.davem@davemloft.net>
References: <148735538165.2347.15424333408396462662.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932303AbdBQUJo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 15:09:44 -0500
In-Reply-To: <148735538165.2347.15424333408396462662.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 17 Feb 2017 18:16:21 +0000

> Change module filename from af-rxrpc.ko to rxrpc.ko so as to be consistent
> with the other protocol drivers.
> 
> Also adjust the documentation to reflect this.
> 
> Further, there is no longer a standalone rxkad module, as it has been
> merged into the rxrpc core, so get rid of references to that.
> 
> Reported-by: Marc Dionne <marc.dionne@auristor.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
