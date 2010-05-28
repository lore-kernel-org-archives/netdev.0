From: David Miller <davem@davemloft.net>
Subject: Re: boot crash in arp_error_report()
Date: Fri, 28 May 2010 01:53:34 -0700 (PDT)
Message-ID: <20100528.015334.229733519.davem@davemloft.net>
References: <20100527.161011.104042698.davem@davemloft.net>
	<20100528080531.GA9893@elte.hu>
	<20100528082440.GA4168@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, torvalds@linux-foundation.org,
	tglx@linutronix.de, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36961
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753028Ab0E1Ix0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 04:53:26 -0400
In-Reply-To: <20100528082440.GA4168@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 28 May 2010 10:24:40 +0200

> Preliminary testing shows that Eric's patch solves the problem.
> 
> Tested-by: Ingo Molnar <mingo@elte.hu>

Thanks a lot for testing Ingo.
