From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [UPDATED PATCH] SGISEEQ: use cached memory access to make driver work on IP28
Date: Tue, 18 Dec 2007 11:30:06 +0100
Message-ID: <20071218103006.GA18598@alpha.franken.de>
References: <20071202103312.75E51C2EB5@solo.franken.de> <47671FEE.90103@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <47671FEE.90103@pobox.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 17, 2007 at 08:18:38PM -0500, Jeff Garzik wrote:
> >Changes to last version:
> >- Use inline functions for dma_sync_* instead of macros (suggested by Ralf)
> >- added Kconfig change to make selection for similair SGI boxes easier
> 
> hrm, could you rediff?  it doesn't seem to apply

sure, against which tree ? I tried netdev-2.6 and it applies without fuzz...

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
