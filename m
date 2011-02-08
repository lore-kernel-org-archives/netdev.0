From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-02-08
Date: Tue, 08 Feb 2011 12:14:56 -0800 (PST)
Message-ID: <20110208.121456.189701516.davem@davemloft.net>
References: <20110208195530.GB6244@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110208195530.GB6244@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 8 Feb 2011 14:55:30 -0500

> Here is the latest round of wireless fixes intended for 2.6.38.
> Included is a carl9170 fix (described as a typo) for receiving buffered
> broadcasts, an iwlagn fix to properly monitor the rfkill switch when
> the interface is down, a mac80211 fix to correctly check for cloned
> skbs when resizing, a null pointer fix for wl1251 if it fails to get
> a beacon, a mac80211 fix related to off-channel tx, an ssb fix for
> using the wrong pointer for getting invariance for pcmcia devices,
> an ath9k double-free fix, and a one-line iwlagn fix to correctly
> describe an antenna configuration.

Pulled, thanks John.
