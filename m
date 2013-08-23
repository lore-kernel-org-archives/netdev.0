From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] fs_enet: silence a build warning (unused
 variable)
Date: Thu, 22 Aug 2013 22:14:18 -0700 (PDT)
Message-ID: <20130822.221418.1582672555558175812.davem@davemloft.net>
References: <1377201313-10420-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, gsi@denx.de
To: agust@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab3HWFOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 01:14:23 -0400
In-Reply-To: <1377201313-10420-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anatolij Gustschin <agust@denx.de>
Date: Thu, 22 Aug 2013 21:55:12 +0200

> From: Gerhard Sittig <gsi@denx.de>
> 
> Since commit 720a43efd30f04a0a492c85fb997361c44fbae05
> (drivers:net: Remove unnecessary OOM messages after netdev_alloc_skb)
> there is a build warning:
> 
> drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c: In function 'tx_skb_align_workaround':
> drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c:586:26: warning: unused variable 'fep'
> 
> Fix it.
> 
> Signed-off-by: Gerhard Sittig <gsi@denx.de>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Applied.
