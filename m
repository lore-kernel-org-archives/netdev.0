From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] more ACSI removal
Date: Sun, 15 Jul 2007 11:28:56 +0200
Message-ID: <20070715092855.GH3565@stusta.de>
References: <20070712234553.GR3492@stusta.de> <Pine.LNX.4.64.0707130909170.8296@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Boaz Harrosh <bharrosh@panasas.com>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, zippel@linux-m68k.org,
	linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33586 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753516AbXGOJ3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 05:29:36 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707130909170.8296@anakin>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 09:10:42AM +0200, Geert Uytterhoeven wrote:
> On Fri, 13 Jul 2007, Adrian Bunk wrote:
> > This patch removes some code that became dead code after the ATARI_ACSI 
> > removal.
> 
> When was it removed?
>...

Jens removed it in commit c2bcf3b8978c291e1b7f6499475c8403a259d4d6

> Gr{oetje,eeting}s,
> 
> 						Geert

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

