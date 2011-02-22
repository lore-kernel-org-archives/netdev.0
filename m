From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-02-22
Date: Tue, 22 Feb 2011 11:55:28 -0800 (PST)
Message-ID: <20110222.115528.245390295.davem@davemloft.net>
References: <20110222193757.GF12153@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110222193757.GF12153@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 22 Feb 2011 14:37:57 -0500

> Here is the latest round of wireless fixes intended for 2.6.38.
> Included are a DMA API fix for p54, an ath5k channel setting fix
> for AR2317 hardware, a WARNING fix related to conn_mon_timer, a lock
> order fix in cfg80211_wext_siwfreq, a bluetooth locking fix, and a
> few simple hardware-enablement patches.
> 
> There are a couple of other notables.  There is an ath9k patch that
> reverts some earlier patches that cause a regression in power usage.
> Also, there is a fairly large ath5k patch to address a regression
> related to fast channel switching.  The patch seems bigger than it
> really is because it moves some code around.  Both of these cite the
> related bugzilla entry.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
