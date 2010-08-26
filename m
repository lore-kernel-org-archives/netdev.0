From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Thu, 26 Aug 2010 16:36:37 +1000
Message-ID: <20100826063637.GD17882@kryten>
References: <1282758634.2487.576.camel@edumazet-laptop>
 <20100825.165759.27789477.davem@davemloft.net>
 <20100826003834.GA17882@kryten>
 <20100825.205302.241913926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, miltonm@bga.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46376 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635Ab0HZGjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 02:39:19 -0400
Content-Disposition: inline
In-Reply-To: <20100825.205302.241913926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Hi Dave,

> Did you test my percpu orphan fix yet?

The machine is running some tests, but I will either get time on it or
replicate the issue on a similar box.

Anton
