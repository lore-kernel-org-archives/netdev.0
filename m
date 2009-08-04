From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Keep interface binding when sending packets with
 ipi_ifindex = 0
Date: Mon, 03 Aug 2009 21:23:23 -0700 (PDT)
Message-ID: <20090803.212323.256579233.davem@davemloft.net>
References: <6c039e090907231439t1def08a4n10978733bee55bec@mail.gmail.com>
	<20090727144402.513369f1.akpm@linux-foundation.org>
	<1248912621.13447.12.camel@merlyn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, chiachi@android.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38493
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751903AbZHDEXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 00:23:14 -0400
In-Reply-To: <1248912621.13447.12.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Wed, 29 Jul 2009 19:10:21 -0500

> I guess Dave's letting this stand.  I'm posting this just to make sure
> this is an explicit decision.

I'm still thinking about this.
