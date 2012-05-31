From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Thu, 31 May 2012 19:03:45 -0400 (EDT)
Message-ID: <20120531.190345.1754322784813248328.davem@davemloft.net>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ncardwell@google.com, therbert@google.com, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758260Ab2EaXDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 19:03:53 -0400
In-Reply-To: <1338501397.2760.1395.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Is the net-next tree open yet?
