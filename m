From: David Miller <davem@davemloft.net>
Subject: Re: request for stable inclusion
Date: Tue, 12 Feb 2013 12:39:53 -0500 (EST)
Message-ID: <20130212.123953.1955246533156235230.davem@davemloft.net>
References: <1448044634.10999492.1359525527955.JavaMail.root@redhat.com>
	<603624767.11006664.1359526575633.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: caiqian@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404Ab3BLRjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 12:39:54 -0500
In-Reply-To: <603624767.11006664.1359526575633.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: CAI Qian <caiqian@redhat.com>
Date: Wed, 30 Jan 2013 01:16:15 -0500 (EST)

> 9c13cb8bb477a83b9a3c9e5a5478a4e21294a760
> tg3: Avoid null pointer dereference in tg3_interrupt in netconsole mode
> 
> daf3ec688e057f6060fb9bb0819feac7a8bbf45c
> tg3: Fix crc errors on jumbo frame receive
> 
> The above 2 commits looks like missing from the stable and the netdev
> stable queues. It was observed that the above issues can be reproduced in
> a kernel that as old as a 2.6.32-based fedora kernel, so I'd like to request
> to include them for 3.0.y, 3.4.y and 3.7.y.

Done.

> 1e47ee8367babe6a5e8adf44a714c7086657b87e
> netfilter: nf_conntrack: fix BUG_ON while removing nf_conntrack with netns
> 
> This one looks like a candidate for 3.7-stable but also missing from the
> queues. Do you agree?

This has already been merged.
