From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling
 to mitigate SYN floods
Date: Tue, 29 May 2012 16:18:13 -0400 (EDT)
Message-ID: <20120529.161813.1372884439455013623.davem@davemloft.net>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	<20120528115226.12068.31850.stgit@localhost.localdomain>
	<m2bol6lqxo.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbrouer@redhat.com, brouer@redhat.com, netdev@vger.kernel.org,
	christoph.paasch@uclouvain.be, eric.dumazet@gmail.com, mph@hoth.dk,
	fw@strlen.de, opurdila@ixiacom.com, hans.schillstrom@ericsson.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724Ab2E2UV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 16:21:56 -0400
In-Reply-To: <m2bol6lqxo.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 29 May 2012 12:37:07 -0700

> Makes sense. Syncookies is a bit obsolete these days of course, due
> to the lack of options. But may be still useful for this.

Please crawl out of your cave, syncookies fully supports all TCP
options these days.
