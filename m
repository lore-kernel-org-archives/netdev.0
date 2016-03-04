From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] RxRPC: Rewrite part 1
Date: Fri, 04 Mar 2016 18:27:14 -0500 (EST)
Message-ID: <20160304.182714.555842688027148255.davem@davemloft.net>
References: <20160304.172010.571829527806753588.davem@davemloft.net>
	<20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
	<6513.1457130818@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760494AbcCDX1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 18:27:18 -0500
In-Reply-To: <6513.1457130818@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 04 Mar 2016 22:33:38 +0000

> David Miller <davem@davemloft.net> wrote:
> 
>> Can you go through and use "unsigned int" instead of just plain
>> "unsigned" in the RxRPC code?
> 
> Do you mind if I leave it to after the rewrite?  I don't particularly want to
> have to rejig all the patches I have.

Sure.
