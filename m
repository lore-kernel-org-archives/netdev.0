From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-04-06
Date: Wed, 06 Apr 2011 14:05:43 -0700 (PDT)
Message-ID: <20110406.140543.02286734.davem@davemloft.net>
References: <20110406200032.GK11941@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110406200032.GK11941@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 6 Apr 2011 16:00:33 -0400

> Here is another batch of fixes intended for 2.6.39...
> 
> This includes a fix to avoid receiving duplicate frames in "cooked"
> monitor mode, a mac80211 documentation fix to avoid developer
> confusion, an rt2x00 fix to avoid cancelling some uninitialized work,
> a wl12xx buffer overflow fix, an email address correction for wl12xx
> module info, a zd1211rw regression fix, a zd1211rw WARNING fix,
> and rtlwifi fix to avoid using some uninitialized variables, a fix
> to broaden the iwl600 hardware supported by iwlagn to match what the
> Windows driver is supporting, a b43 fix to allocate properly sized
> receive buffers, and some stuff related to device IDs.
> 
> Please let me know if there are problems!

Pulled, thanks John.
