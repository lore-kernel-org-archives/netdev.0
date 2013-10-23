From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] net: wan: sbni: remove assembly crc32 code
Date: Wed, 23 Oct 2013 04:11:56 +0200
Message-ID: <20131023021156.GG29695@two.firstfloor.org>
References: <1382458346-24811-1-git-send-email-andi@firstfloor.org>
 <1382458346-24811-12-git-send-email-andi@firstfloor.org>
 <20131022.135928.2040131908206663695.davem@davemloft.net>
 <20131022183625.GA4382@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	ak@linux.intel.com, netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131022183625.GA4382@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 22, 2013 at 08:36:25PM +0200, Sebastian Andrzej Siewior wrote:
> 
> There is also a C function doing the same thing. Unless the asm code is
> 110% faster we could stick to the C function.

I have no idea if it is or not. But doing it this way would be
acceptable for me.

Thanks for the patch.

-Andi
