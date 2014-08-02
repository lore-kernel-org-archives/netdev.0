From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] inet: frags: cleanup and kmem_cache use
Date: Sat, 02 Aug 2014 15:32:00 -0700 (PDT)
Message-ID: <20140802.153200.535581662112020791.davem@davemloft.net>
References: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, fw@strlen.de,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, alex.aring@gmail.com, eric.dumazet@gmail.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbaHBWcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 18:32:02 -0400
In-Reply-To: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Fri,  1 Aug 2014 12:29:42 +0200

> This patchset does a couple of small cleanups in patches 1-5 and then in
> patch 06 it introduces the use of kmem_cache for allocation/freeing of
> inet_frag_queue+header objects.
> 
> v2: Broke up patch 02 into 3 patches as David suggested

Series applied, thanks Nikolay.
