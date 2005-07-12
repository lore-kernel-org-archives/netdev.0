From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: 12 Jul 2005 23:26:41 +0200
Message-ID: <p73irzf1zse.fsf@bragg.suse.de>
References: <20050712.133404.52118192.davem@davemloft.net>
	<000a01c58724$ca41a7c0$4f10100a@pc.s2io.com>
	<20050712.140411.41107257.davem@davemloft.net>
	<20050712210704.GA11622@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050712210704.GA11622@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@infradead.org> writes:
> 
> And that doesn't help either, CONFIG_IA64_SGI_SN2 isn't used in practice,
> any production Altix with 26 kernels runs CONFIG_IA64_GENERIC kernels.

At least SLES9/ia64 has a SN2 kernel.

-Andi
