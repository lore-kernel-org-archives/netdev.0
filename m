From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [UPDATED PATCH] SGISEEQ: use cached memory access to make driver
 work on IP28
Date: Tue, 18 Dec 2007 19:38:13 -0500
Message-ID: <476867F5.3070006@pobox.com>
References: <20071202103312.75E51C2EB5@solo.franken.de> <47671FEE.90103@pobox.com> <20071218103006.GA18598@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36265 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758923AbXLSAiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 19:38:20 -0500
In-Reply-To: <20071218103006.GA18598@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Bogendoerfer wrote:
> On Mon, Dec 17, 2007 at 08:18:38PM -0500, Jeff Garzik wrote:
>>> Changes to last version:
>>> - Use inline functions for dma_sync_* instead of macros (suggested by Ralf)
>>> - added Kconfig change to make selection for similair SGI boxes easier
>> hrm, could you rediff?  it doesn't seem to apply
> 
> sure, against which tree ? I tried netdev-2.6 and it applies without fuzz...

It needs to be the 'upstream' branch of netdev-2.6.

The default netdev-2.6.git branch, master, is a 100% vanilla duplicate 
of Linus's git repository.

(this permits a common practice of presenting logs and diffs using git's 
branch..branch notation)

	Jeff



