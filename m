From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [tipc-discussion] [RFC: 2.6 patch] net/tipc/: possible cleanups
Date: Sun, 25 Feb 2007 17:14:11 +0100
Message-ID: <20070225161411.GX12392@stusta.de>
References: <20070223221657.GA10153@infradead.org> <AF1602CB2550CE4381C0C75118A7856BA2ACC6@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Jon Maloy <jon.maloy@ericsson.com>, per.liden@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:43826 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964976AbXBYQOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 11:14:12 -0500
Content-Disposition: inline
In-Reply-To: <AF1602CB2550CE4381C0C75118A7856BA2ACC6@ala-mail02.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 24, 2007 at 04:19:19PM -0800, Stephens, Allan wrote:
>...
> 2) There are portions of TIPC's native API which are intended for use by
> driver programmers, but which are not being used by any code that is
> currently in the kernel.  While removing these API's from TIPC will only
> impact these "freeloaders", it has the potential to discourage future
> programmers who *do* want to contribute their work to the kernel by
> removing API's that are apparently necessary/useful when doing coding of
> this sort.

It can be re-added at any time when an in-kernel user comes.

But the most interesting question is:
Why is noone interested in getting his TIPC using drivers merged?

> Regards,
> Al
>...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

