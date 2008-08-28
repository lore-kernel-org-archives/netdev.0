From: David Miller <davem@davemloft.net>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 13:47:01 -0700 (PDT)
Message-ID: <20080828.134701.116492932.davem@davemloft.net>
References: <48B70AAA.7010504@hp.com>
	<20080828.133223.119110675.davem@davemloft.net>
	<48B70E74.2000800@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmalicki@metacarta.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38219
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754637AbYH1UrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 16:47:06 -0400
In-Reply-To: <48B70E74.2000800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 28 Aug 2008 13:45:40 -0700

> Given that there are no guarantees that a packet arriving on NIC 1
> and timestamped either by the NIC HW or the driver will actually hit
> the application before a packet arriving on NIC2, just how long are
> these financial services applications going to wait around before
> executing the trade carried in the packet arriving on NIC1?

I have no idea.

They also care about trade processing latency btw.
