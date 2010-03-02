From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [rfc/rft][patch] should use scheduler sync hint in
 tcp_prequeue()?
Date: Tue, 02 Mar 2010 12:32:05 +0100
Message-ID: <1267529525.25158.40.camel@laptop>
References: <1267522901.25906.101.camel@marge.simson.net>
	 <1267529273.2964.111.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <efault@gmx.de>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267529273.2964.111.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-03-02 at 12:27 +0100, Eric Dumazet wrote:
> My Q6600 has shared caches 

Isn't core2quad a dual die construct, having 2 cache domains?
