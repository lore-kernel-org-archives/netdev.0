From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-06-24
Date: Fri, 24 Jun 2011 13:30:18 -0700 (PDT)
Message-ID: <20110624.133018.633722812311589592.davem@davemloft.net>
References: <20110624184949.GC4793@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110624184949.GC4793@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 24 Jun 2011 14:49:49 -0400

> Dave,
> 
> Here is another batch of fixes intended for 3.0.  Included are too
> rtlwifi fixes from Larry:  a regression that broke firmware loading for
> rtl8292cu; and a fix to arbitrate between two devices that share the
> same PCI ID but are handled by different drivers...yeah.
> 
> The rest are Bluetooth fixes -- quoth Gustavo:
> 
> 	Three regressions fix intended for 3.0. Two of them fix a
> 	change made in our HCI security process for 3.0. The third
> 	one fixes an issue with non-SSP devices.  All of them are
> 	critical fixes. They should be in 3.0. Please pull!  Thanks.
> 
> Please let me know if there are problems!

Pulled, thanks!
