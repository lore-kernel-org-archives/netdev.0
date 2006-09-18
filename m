From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Mon, 18 Sep 2006 06:56:55 -0700 (PDT)
Message-ID: <20060918.065655.128444024.davem@davemloft.net>
References: <20060904160045.GA15599@ms2.inr.ac.ru>
	<20060918.003110.88477231.davem@davemloft.net>
	<20060918103705.GB1096@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56211
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965231AbWIRN5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 09:57:05 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060918103705.GB1096@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Mon, 18 Sep 2006 14:37:05 +0400

> > It looks perfectly fine to me, would you like me to apply it
> > Alexey?
> 
> Yes, I think it is safe.

Ok, I'll put this into net-2.6.19 for now.  Thanks.
