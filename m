From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v3] fasync: RCU and fine grained locking
Date: Wed, 21 Apr 2010 16:20:24 -0700 (PDT)
Message-ID: <20100421.162024.248644052.davem@davemloft.net>
References: <1271257027.16881.1663.camel@edumazet-laptop>
	<1271259264.16881.1703.camel@edumazet-laptop>
	<1271274935.16881.1746.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, laijs@cn.fujitsu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33825
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754234Ab0DUXUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:20:19 -0400
In-Reply-To: <1271274935.16881.1746.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Apr 2010 21:55:35 +0200

> [PATCH net-next-2.6 v3] fasync: RCU and fine grained locking

BTW, just to be clear I made sure to apply V3 of this
patch not the initial submission :-)
