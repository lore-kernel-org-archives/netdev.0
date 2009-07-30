From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: fix coalescing setup in ethtool support
Date: Thu, 30 Jul 2009 14:21:03 -0700 (PDT)
Message-ID: <20090730.142103.94025463.davem@davemloft.net>
References: <1248857517-8270-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	b06378@freescale.com
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47409
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752121AbZG3VU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 17:20:56 -0400
In-Reply-To: <1248857517-8270-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>
Date: Wed, 29 Jul 2009 16:51:57 +0800

> Parameter order for using mk_ic_value(count, time) was reversed,
> the patch fixes this.
> 
> Signed-off-by: Jiajun Wu <b06378@freescale.com>
> Signed-off-by: Li Yang <leoli@freescale.com>

Applied, thanks.
