From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] rxrpc: Miscellaneous fixes
Date: Tue, 09 Aug 2016 12:57:02 -0700 (PDT)
Message-ID: <20160809.125702.623430354243838572.davem@davemloft.net>
References: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36735 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbcHIT5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 15:57:05 -0400
Received: by mail-pf0-f195.google.com with SMTP id y134so1380922pfg.3
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 12:57:04 -0700 (PDT)
In-Reply-To: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 09 Aug 2016 17:33:12 +0100

> Here are a bunch of miscellaneous fixes to AF_RXRPC:
> 
>  (*) Fix an uninitialised pointer.
> 
>  (*) Fix error handling when we fail to connect a call.
> 
>  (*) Fix a NULL pointer dereference.
> 
>  (*) Fix two occasions where a packet is accessed again after being queued
>      for someone else to deal with.
> 
>  (*) Fix a missing skb free.
> 
> ---
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-fixes
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-fixes-20160809

Pulled, thanks David.
