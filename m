From: David Miller <davem@davemloft.net>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm,
 for adaptive dcache hash table sizing (resend)
Date: Tue, 07 Oct 2008 14:05:09 -0700 (PDT)
Message-ID: <20081007.140509.48442086.davem@davemloft.net>
References: <20081007070225.GB5959@wotan.suse.de>
	<48EB11BB.2060704@cosmosbay.com>
	<20081007080656.GB16143@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org, paulmck@us.ibm.com
To: npiggin@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56939
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751951AbYJGVFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 17:05:33 -0400
In-Reply-To: <20081007080656.GB16143@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Piggin <npiggin@suse.de>
Date: Tue, 7 Oct 2008 10:06:56 +0200

> Hmm, that is interesting. What are the exact semantics of this rt_cache
> file?

It dumps the whole set of elements in the routing cache hash table.
