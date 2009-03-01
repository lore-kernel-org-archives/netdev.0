From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: 2.6.29 e100.c non-MII support status? (Re: [GIT]: Networking)
Date: Sun, 1 Mar 2009 22:24:12 +0100
Message-ID: <20090301212412.GA13210@rhlx01.hs-esslingen.de>
References: <20081228.000118.121541932.davem@davemloft.net> <20081229102515.GA17171@rhlx01.hs-esslingen.de> <20081229091728.d869f1c1.akpm@linux-foundation.org> <9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com> <20081230120756.GA5393@rhlx01.hs-esslingen.de> <20090228203757.GA18850@rhlx01.hs-esslingen.de> <9929d2390903010257p7c6fb367ga974767605033bc9@mail.gmail.com>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@lisas.de, Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, bunk@kernel.org,
	auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:34505 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360AbZCAVYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 16:24:15 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390903010257p7c6fb367ga974767605033bc9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Mar 01, 2009 at 02:57:46AM -0800, Jeff Kirsher wrote:
> I am personally sorry that nothing has been done regarding this patch.
>  I still have this patch in my local tree.  I admit that this patch
> has been on the low priority list, so I will make sure the patch is
> current this week and respond accordingly this week.

The whole thing has been somewhat low-priority indeed
given the probable age of some non-MII contenders. OTOH it would be quite sad
(and locally problematic) to see support for those non-MII cards vanish
come 2.6.29.
Subsequently it would then be nice to devise non-MII support
in some structured way that enables us to support them without
much burden (code-wise) on proper standards-supporting MII cards.

Thank you,

Andreas Mohr
