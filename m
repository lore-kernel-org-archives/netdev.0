From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8169: adjust __rtl8169_set_features
Date: Tue, 16 Sep 2014 15:56:27 -0400 (EDT)
Message-ID: <20140916.155627.1263306577960098199.davem@davemloft.net>
References: <20140916000321.GA19564@electric-eye.fr.zoreil.com>
	<1394712342-15778-42-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, romieu@fr.zoreil.com
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-42-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 16 Sep 2014 11:40:47 +0800

> Remove the "changed" test in __rtl8169_set_features(). Instead, do
> simple test in rtl8169_set_features().
> 
> Set the RxChkSum and RxVlan through __rtl8169_set_features() in
> rtl_open().
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
