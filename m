From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [UPDATED PATCH] SGISEEQ: use cached memory access to make
	driver work on IP28
Date: Wed, 19 Dec 2007 18:27:50 +0100
Message-ID: <20071219172750.GA9717@linux-mips.org>
References: <20071202103312.75E51C2EB5@solo.franken.de> <47671FEE.90103@pobox.com> <20071218103006.GA18598@alpha.franken.de> <476867F5.3070006@pobox.com> <20071219124235.GA7550@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20071219124235.GA7550@alpha.franken.de>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 19, 2007 at 01:42:36PM +0100, Thomas Bogendoerfer wrote:

> - Use inline functions for dma_sync_* instead of macros 
> - added Kconfig change to make selection for similair SGI boxes easier
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
