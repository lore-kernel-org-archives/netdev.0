From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Fri, 01 Jun 2012 13:46:59 -0400 (EDT)
Message-ID: <20120601.134659.621228924477728327.davem@davemloft.net>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
	<20120531.190345.1754322784813248328.davem@davemloft.net>
	<1338526137.2760.1425.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ncardwell@google.com, therbert@google.com, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759848Ab2FARyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 13:54:55 -0400
In-Reply-To: <1338526137.2760.1425.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 Jun 2012 06:48:57 +0200

> RFC is like 'I throw a patch, I am not even 50% confident of it, please
> comment and fix my bugs'. Most busy people just ignore it.

And I will ignore it too if you put RFC in the subject line :)
