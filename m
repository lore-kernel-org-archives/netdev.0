From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: cls_flow: add key rxhash
Date: Sat, 21 Aug 2010 23:41:03 -0700 (PDT)
Message-ID: <20100821.234103.189711938.davem@davemloft.net>
References: <1282407795-3449-1-git-send-email-xiaosuo@gmail.com>
	<1282426892.3532.5.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751283Ab0HVGks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 02:40:48 -0400
In-Reply-To: <1282426892.3532.5.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sat, 21 Aug 2010 17:41:32 -0400

> On Sun, 2010-08-22 at 00:23 +0800, Changli Gao wrote:
>> We can use rxhash to classify the traffic into flows. As rxhash maybe
>> supplied by NIC or RPS, it is cheaper.
>> 
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Nice idea.
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Sometimes the simplest patches are the best :-)

Applied, thanks Changli!
