From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ne: fix memory leak in ne_drv_probe()
Date: Mon, 05 Jul 2010 20:08:16 -0700 (PDT)
Message-ID: <20100705.200816.57450933.davem@davemloft.net>
References: <1278170444-8170-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, joe@perches.com,
	anemo@mba.ocn.ne.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37160
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755039Ab0GFDIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 23:08:02 -0400
In-Reply-To: <1278170444-8170-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Sat,  3 Jul 2010 19:20:42 +0400

> net_device allocated with alloc_eip_netdev() must be freed.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied, thanks.
