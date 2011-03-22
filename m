From: David Miller <davem@davemloft.net>
Subject: Re: [held lock freed] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 18:16:30 -0700 (PDT)
Message-ID: <20110321.181630.35037636.davem@davemloft.net>
References: <20110321125320.GA23490@elte.hu>
	<1300714346.2884.284.camel@edumazet-laptop>
	<20110321161528.GA28580@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl,
	tglx@linutronix.de, arnd@arndb.de
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755227Ab1CVBPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:15:52 -0400
In-Reply-To: <20110321161528.GA28580@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Mar 2011 17:15:28 +0100

> 
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> Here is a probable fix.
>> 
>> [PATCH] ipx: fix ipx_release()
> 
> This patch did the trick - thanks Eric!
> 
> Tested-by: Ingo Molnar <mingo@elte.hu>

Applied, thanks everyone.
