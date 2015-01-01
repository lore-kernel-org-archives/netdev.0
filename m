From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/6] support GMAC driver for RK3288
Date: Wed, 31 Dec 2014 19:15:38 -0500 (EST)
Message-ID: <20141231.191538.585375391107637966.davem@davemloft.net>
References: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, eddie.cai@rock-chips.com
To: roger.chen@rock-chips.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbAAAPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 19:15:47 -0500
In-Reply-To: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roger Chen <roger.chen@rock-chips.com>
Date: Mon, 29 Dec 2014 17:42:32 +0800

> Roger Chen (6):
>   patch1: add driver for Rockchip RK3288 SoCs integrated GMAC
>   patch2: define clock ID used for GMAC
>   patch3: modify CRU config for Rockchip RK3288 SoCs integrated GMAC
>   patch4: dts: rockchip: add gmac info for rk3288
>   patch5: dts: rockchip: enable gmac on RK3288 evb board
>   patch6: add document for Rockchip RK3288 GMAC
> 
> Tested on rk3288 evb board:
> Execute the following command to enable ethernet,
> set local IP and ping a remote host.
> 
> busybox ifconfig eth0 up
> busybox ifconfig eth0 192.168.1.111
> ping 192.168.1.1

Series applied to net-next, thanks.
