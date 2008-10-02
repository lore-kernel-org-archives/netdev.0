From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
Date: Thu, 2 Oct 2008 12:47:48 -0700
Message-ID: <20081002124748.638c95ff.akpm@linux-foundation.org>
References: <20081002130504.927878499@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40229 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754093AbYJBTtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 15:49:06 -0400
In-Reply-To: <20081002130504.927878499@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 Oct 2008 15:05:04 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Let's get this ball rolling...

I don't think we're really able to get any MM balls rolling until we
get all the split-LRU stuff landed.  Is anyone testing it?  Is it good?

