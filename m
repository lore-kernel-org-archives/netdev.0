From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2011-11-30
Date: Wed, 30 Nov 2011 16:21:57 -0500 (EST)
Message-ID: <20111130.162157.1166144157202128144.davem@davemloft.net>
References: <20111130193907.GB2477@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111130193907.GB2477@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 30 Nov 2011 14:39:07 -0500

> There is an nl80211 fix for validating user input to prevent a buffer
> underrun, a mac80211 race fix to prevent a WARN_ON, a mac80211 fix to
> avoid trying to stop a single aggregation session twice, a mac80211 fix
> for a race condition that could cause a crash when an addBA response
> came late, the partial reversion of an ath9k change that broke wireless
> on Ferrari One laptops, and a fix for an rtlwifi deadlock.
> 
> Please let me know if there are problems!

Applied, thanks.
