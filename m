From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-02-08
Date: Wed, 08 Feb 2012 19:13:12 -0500 (EST)
Message-ID: <20120208.191312.797325617283169736.davem@davemloft.net>
References: <20120208203702.GE2929@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120208203702.GE2929@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 8 Feb 2012 15:37:02 -0500

> This is a batch of fixes intended for 3.3.
> 
> Included is a fix for an association failure bug with mwifiex, and a fix
> for a NULL pointer deref in that same driver.  There is also an ath9k
> fix for a WEP-related regression, and another ath9k fix for an RTS/CTS
> timeout regression.  A third ath9k fix address an oops during driver
> initialization.  Also included is a zd1211rw fix for an issue where the
> firmware would corrupt the duration_id setting and cause devices to be
> unable to connect to zd1211rw-based APs.  A fix from me to reduce some
> log spam from ath9k rounds-out the bunch.
> 
> Please let me know if there are problems!

Pulled, thanks John.
