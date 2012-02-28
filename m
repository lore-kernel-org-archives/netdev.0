From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-02-27
Date: Mon, 27 Feb 2012 21:18:30 -0500 (EST)
Message-ID: <20120227.211830.905259317987117782.davem@davemloft.net>
References: <20120227201507.GE26664@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120227201507.GE26664@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 27 Feb 2012 15:15:07 -0500

> This is a batch of fixes intended for 3.3.
> 
> The biggest fix comes from Felix, where he moves around some code
> in ath9k in order to avoid a crash reported to him by a user on IRC.
> Also included is an rt2x00 fix from Gabor Juhos for a possible NULL
> pointer dereference, an iwlwifi fix from Johannes Berg for a bug that
> led to incorrectly removing unicast keys (and dropping connections),
> a mac80211 fix from Mohammed Shafi Shajakhan to properly initialize
> a structure used by the rate control algorithms, another mac80211
> fix from Mohammed to avoid a WARNING when changing from monitor mode
> to managed mode, a brcmsmac fix from Arend van Spriel to avoid an
> endless retry of A-MPDU retransmits, and another fix from Arend to
> avoid some log spam coming from brcmsmac.

Pulled, thanks John.
