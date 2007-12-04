From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [UPDATED PATCH] SGISEEQ: use cached memory access to make
	driver work on IP28
Date: Tue, 4 Dec 2007 21:05:31 +0000
Message-ID: <20071204210531.GB775@linux-mips.org>
References: <20071202103312.75E51C2EB5@solo.franken.de> <4755B536.8070003@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	netdev@vger.kernel.org, linux-mips@linux-mips.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <4755B536.8070003@pobox.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 04, 2007 at 03:14:46PM -0500, Jeff Garzik wrote:

>> Changes to last version:
>> - Use inline functions for dma_sync_* instead of macros (suggested by Ralf)
>> - added Kconfig change to make selection for similair SGI boxes easier
>
> Has Ralf ACK'd this updated version?

Acked-by: Ralf Baechle <ralf@linux-mips.org>

> This is for 2.6.25 (i.e. not a bug fix for 2.6.24-rc) I presume?

Yes.  IP28 support it scheduled to be merged for 2.6.25.

  Ralf
