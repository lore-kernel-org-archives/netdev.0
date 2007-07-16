From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [2.6 patch] more ACSI removal
Date: Mon, 16 Jul 2007 14:15:42 +0200
Message-ID: <20070716121541.GH5195@kernel.dk>
References: <20070712234553.GR3492@stusta.de> <Pine.LNX.4.64.0707130909170.8296@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, Boaz Harrosh <bharrosh@panasas.com>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, zippel@linux-m68k.org,
	linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:16934 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618AbXGPMQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 08:16:25 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707130909170.8296@anakin>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13 2007, Geert Uytterhoeven wrote:
> On Fri, 13 Jul 2007, Adrian Bunk wrote:
> > This patch removes some code that became dead code after the ATARI_ACSI 
> > removal.
> 
> When was it removed? Nobody seems to have informed the m68k people...

It hasn't even been compiling for 5 years, so it can't be that big of an
issue. I thought you had been cc'ed on the discussion, but I can't seem
to find the thread now even.

-- 
Jens Axboe

