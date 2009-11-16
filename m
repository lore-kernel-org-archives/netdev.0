From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 02:48:39 -0800 (PST)
Message-ID: <20091116.024839.257258321.davem@davemloft.net>
References: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@vyatta.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752313AbZKPKsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:48:23 -0500
In-Reply-To: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 16 Nov 2009 17:53:29 +0800

> act_mirred: optimization.
> 
> move checking if eaction is valid in tcf_mirred_init()
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Also applied, thank you.
