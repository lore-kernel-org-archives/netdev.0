From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] virtio: simplify virtio_ring.
Date: Fri, 05 Sep 2014 14:27:45 -0700 (PDT)
Message-ID: <20140905.142745.359233584859651695.davem@davemloft.net>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luto@amacapital.net, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaIEV1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:27:45 -0400
In-Reply-To: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed,  3 Sep 2014 13:59:13 +0930

> I resurrected these patches after prompting from Andy Lutomirski's
> recent patches.  I put them on the back-burner because vring_bench
> had a 15% slowdown on my laptop: pktgen testing revealed a speedup,
> if anything, so I've cleaned them up.

If you want to merge this via your virtio tree that's fine with me.

For virtio_net:

Acked-by: David S. Miller <davem@davemloft.net>
