From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-08-10
Date: Fri, 10 Aug 2012 16:27:19 -0700 (PDT)
Message-ID: <20120810.162719.2120897808611880641.davem@davemloft.net>
References: <20120810183351.GD1950@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120810183351.GD1950@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 10 Aug 2012 14:33:51 -0400

> Here is a handful of fixes intended for 3.6.
> 
> Daniel Drake offers a cfg80211 fix to consume pending events before
> taking a wireless device down.  This prevents a resource leak.
> 
> Stanislaw Gruszka gives us a fix for a NULL pointer dereference in
> rt61pci.
> 
> Johannes Berg provides an iwlwifi patch to disable "greenfield" mode.
> Use of that mode was causing a rate scaling problem in for iwlwifi.
> 
> Please let me know if there are problems!

Pulled, thanks John.
