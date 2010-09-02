From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: arp: code cleanup
Date: Thu, 02 Sep 2010 10:12:35 -0700 (PDT)
Message-ID: <20100902.101235.246522413.davem@davemloft.net>
References: <1283435811-8875-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, joe@perches.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756067Ab0IBRMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 13:12:19 -0400
In-Reply-To: <1283435811-8875-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu,  2 Sep 2010 21:56:51 +0800

> Clean the code up according to Documentation/CodingStyle.
> 
> Don't initialize the variable dont_send in arp_process().
> 
> Remove the temporary varialbe flags in arp_state_to_flags().
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
