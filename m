From: David Miller <davem@davemloft.net>
Subject: Re: 10G intel cards - streaming for over than 30 minutes
Date: Mon, 08 Dec 2008 14:56:44 -0800 (PST)
Message-ID: <20081208.145644.42607536.davem@davemloft.net>
References: <5d96567b0812081441i4014fb6cvba782e51d9a30eb5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raziebe@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754357AbYLHW4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 17:56:44 -0500
In-Reply-To: <5d96567b0812081441i4014fb6cvba782e51d9a30eb5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raz <raziebe@gmail.com>
Date: Tue, 9 Dec 2008 00:41:03 +0200

> Well, one of my interfaces decided to go to sleep.
> 
> ixgbe: eth4: ixgbe_watchdog_task: NIC Link is Up 10 Gbps, Flow Control: None
> NETDEV WATCHDOG: eth4: transmit timed out
> 
> Does anyone know whether this is a bug that was fixed ( my kernel
> 2.6.18-8.el5 ).

Contact the vendor who supplied you with that kernel for help.

If you can reproduce this with the upstream kernel, please provide
such traces so we can look into it.

Thanks.
