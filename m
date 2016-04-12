From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] RxRPC: 2nd rewrite part 1
Date: Mon, 11 Apr 2016 21:26:09 -0400 (EDT)
Message-ID: <20160411.212609.1357126698944936132.davem@davemloft.net>
References: <20160411.153511.1531573815825221764.davem@davemloft.net>
	<20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
	<15783.1460412099@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbcDLB0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 21:26:15 -0400
In-Reply-To: <15783.1460412099@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Mon, 11 Apr 2016 23:01:39 +0100

> David Miller <davem@davemloft.net> wrote:
> 
>> Series applied, but I had to fix up some trailing whitespace (reported by
>> GIT) by hand.
> 
> Do you perchance have a git hook script for checking for trailing whitespace?

Just try to apply the series yourself with "git am", that's what I do.

You can do "git apply --check --whitespace=error-all" on individual
patches, but that doesn't work for a series.
