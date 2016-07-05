From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix runtime function for RTL8152
Date: Tue, 05 Jul 2016 10:22:56 -0700 (PDT)
Message-ID: <20160705.102256.248480790659058270.davem@davemloft.net>
References: <1394712342-15778-207-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbcGERW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 13:22:57 -0400
In-Reply-To: <1394712342-15778-207-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 5 Jul 2016 16:11:46 +0800

> The RTL8152 doesn't have U1U2 and U2P3 features, so use different
> runtime functions for RTL812 and RTL8153 by adding autosuspend_en()
> to rtl_ops.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
