From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Tue, 18 Sep 2007 13:32:40 -0700 (PDT)
Message-ID: <20070918.133240.35800852.davem@davemloft.net>
References: <20070918120438.GA9121@gondor.apana.org.au>
	<E1IXbqs-0002Od-00@gondolin.me.apana.org.au>
	<46F032D5.7020806@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mostrows@speakeasy.net,
	paulus@samba.org, toralf.foerster@gmx.de, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753241AbXIRUcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 16:32:55 -0400
In-Reply-To: <46F032D5.7020806@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Tue, 18 Sep 2007 21:19:33 +0100

> This one causes my test system to lock up. I'll investigate. Please 
> don't apply this patch for now.

I'll make sure not to push this until we figure out what's
wrong, thanks for checking James.
