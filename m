From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 07/06]: Fix endless loops (part 5): netem/tbf/hfsc
 ->requeue failures
Date: Wed, 29 Nov 2006 17:37:53 -0800 (PST)
Message-ID: <20061129.173753.18302917.davem@davemloft.net>
References: <4561C32F.7000702@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57319
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967809AbWK3Bhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:37:55 -0500
To: kaber@trash.net
In-Reply-To: <4561C32F.7000702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 20 Nov 2006 16:01:03 +0100

> I forgot to fix one (AFAICT purely theoretical) case ..

Also applied to net-2.6.20, thanks a lot Patrick.
