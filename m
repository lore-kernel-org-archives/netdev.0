From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] r8169: Enable RX_MULTI_EN for
 RTL_GIGA_MAC_VER_41~48
Date: Wed, 02 Mar 2016 14:00:46 -0500 (EST)
Message-ID: <20160302.140046.973657930635567118.davem@davemloft.net>
References: <1456937955-2762-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbcCBTAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:00:48 -0500
In-Reply-To: <1456937955-2762-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chunhao Lin <hau@realtek.com>
Date: Thu, 3 Mar 2016 00:59:15 +0800

> For RTL8168G/RTL8168H/RTL8411B/RTL8107E, enable this flag to eliminate
> message "AMD-Vi: Event logged [IO_PAGE_FAULT device=01:00.0 domain=0x0002
> address=0x0000000000003000 flags=0x0050] in dmesg.
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>

Applied, thanks.
