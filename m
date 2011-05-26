From: Luciano Coelho <coelho@ti.com>
Subject: Re: [PATCH][Trivial] mac80211: Remove duplicate linux/slab.h
 include from net/mac80211/scan.c
Date: Thu, 26 May 2011 12:06:31 +0300
Message-ID: <1306400791.19876.41.camel@cumari>
References: <alpine.LNX.2.00.1105261048570.17400@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, trivial@kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1105261048570.17400@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-05-26 at 10:53 +0200, Jesper Juhl wrote: 
> Commit 79f460ca49d8d5700756ab7071c951311c7f29cc add a duplicate 
> linux/slab.h include to net/mac80211/scan.c - remove it.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---

Hmmm... indeed! Must have been a rebase mistake I made.  Thanks for
fixing it.

Acked-by: Luciano Coelho <coelho@ti.com>


-- 
Cheers,
Luca.
