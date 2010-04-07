From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-04-07
Date: Wed, 07 Apr 2010 16:42:24 -0700 (PDT)
Message-ID: <20100407.164224.60848141.davem@davemloft.net>
References: <20100407182832.GA2995@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100407182832.GA2995@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 7 Apr 2010 14:28:32 -0400

> Here is a batch of fixes intended for 2.6.34.  Included is a variable
> initialization required for some ath9k hardware to function reliably,
> some RCU annotation to avoid some warnings in mac80211, and a fix for
> a regression relating to 802.11s mesh networking.  Also included are
> several iwlwifi fixes, include the elimination of an order-4 allocation
> during resume, avoidance of a the BUG_ON in the rate scaling routines,
> and the elimination of a DMA API warning during module removal.
> The iwlwifi patches are a little larger than I would like, but the
> fixes seem legitimate and worthwhile to me.

I guess nobody takes me seriously when I say tone down the rate
of fixes to the absolute minimum.

Oh well, what can I do, if even the most core people can't be bothered
to listen to my requests.

And people wonder why we need 8 or 9 RCs to get a release out.

Pulled.
