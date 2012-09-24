From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Mon, 24 Sep 2012 16:53:49 -0400 (EDT)
Message-ID: <20120924.165349.1507020746048987565.davem@davemloft.net>
References: <20120924171152.GA26454@redhat.com>
	<1348507878.26828.1271.camel@edumazet-glaptop>
	<20120924181152.GA31183@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ycheng@google.com, ja@ssi.bg,
	netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186Ab2IXUxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:53:53 -0400
In-Reply-To: <20120924181152.GA31183@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 24 Sep 2012 14:11:52 -0400

> tangent: Is there any kind of networking correctness suite
> other than fuzz testers like isic etc ? 

If people want to work on this I'm willing to maintain the
tree.
