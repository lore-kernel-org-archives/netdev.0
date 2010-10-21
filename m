From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: remove the unused parameter of
 qdisc_create_dflt()
Date: Thu, 21 Oct 2010 03:16:46 -0700 (PDT)
Message-ID: <20101021.031646.232745392.davem@davemloft.net>
References: <1287270248-13190-1-git-send-email-xiaosuo@gmail.com>
	<1287404425.3664.186.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, netem@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43799
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755947Ab0JUKQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:16:23 -0400
In-Reply-To: <1287404425.3664.186.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Mon, 18 Oct 2010 08:20:25 -0400

> On Sun, 2010-10-17 at 07:04 +0800, Changli Gao wrote:
>> The first parameter dev isn't in use in qdisc_create_dflt().
> 
> And we can derive it from netdev_queue if ever needed in the future.
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks.
