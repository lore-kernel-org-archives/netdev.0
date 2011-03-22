From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-03-22
Date: Tue, 22 Mar 2011 14:36:22 -0700 (PDT)
Message-ID: <20110322.143622.189692906.davem@davemloft.net>
References: <20110322174616.GB2512@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110322174616.GB2512@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 22 Mar 2011 13:46:17 -0400

> Here is a batch of fixes intended for 2.6.39.  Included are a lock
> leak fix for iwlwifi, a "hold the lock longer" fix for orinoco, an
> rtlwifi fix for a memset argument ordering problem, a sta structure
> initialization fix for mac80211, an ath9k NULL pointer fix, a
> kernel-doc fix, and a handful of device IDs.

Pulled, thanks a lot John.
