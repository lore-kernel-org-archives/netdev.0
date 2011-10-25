From: David Miller <davem@davemloft.net>
Subject: Re: Linux 3.1-rc9
Date: Tue, 25 Oct 2011 19:18:19 -0400 (EDT)
Message-ID: <20111025.191819.1527543903045617185.davem@davemloft.net>
References: <CA+55aFwzAM6zhqCYJwoRxCdLJB+h84BDqzhF0RNQ6Jg9SQFjSA@mail.gmail.com>
	<20111025.050113.1678938946604302787.davem@davemloft.net>
	<alpine.LFD.2.02.1110251419170.21837@ionos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, sim@hostway.ca,
	netdev@vger.kernel.org, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	schwidefsky@de.ibm.com, mingo@elte.hu
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.02.1110251419170.21837@ionos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 25 Oct 2011 14:30:50 +0200 (CEST)

> Subject: net: Unlock sock before calling sk_free()
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Good spotting, applied, thanks Thomas!
