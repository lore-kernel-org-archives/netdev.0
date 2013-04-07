From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] 802.15.4 and 6LoWPAN Buffering Fixes
Date: Sun, 07 Apr 2013 17:06:54 -0400 (EDT)
Message-ID: <20130407.170654.613017631446034661.davem@davemloft.net>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
	<1364997658-16498-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364997658-16498-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Wed,  3 Apr 2013 10:00:54 -0400

> Version 2 of this patch series:
> 
> Differences from v1:
> 
> 1. Patches previously numbered 5 and 6 were squashed (to become current
> patch #4) at the request of Alexander Smirnov.
> 
> 2. Current patch #2 had extraneous braces removed.
> 
> 3. Current patch #1 was changed. It is now a patch to make mac802154 _not_
> retry sending packets on failure. I believe this to be consistent with the
> 802.15.4 specification (Section 7.5.6.4.3 of IEEE 802.15.4-2006)

Series applied, thanks.
