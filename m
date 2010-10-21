From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] r8169 patches for net-next v2
Date: Thu, 21 Oct 2010 01:35:13 -0700 (PDT)
Message-ID: <20101021.013513.115924529.davem@davemloft.net>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, kirjanov@gmail.com
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33474
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750915Ab0JUIev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 04:34:51 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Thu, 21 Oct 2010 10:25:35 +0200

> v1 -> v2
> - update to current code and some minor changes/cleanups
> - do not return NETDEV_TX_BUSY from start_xmit when mapping fail (patch 1)
> - add missing unlikely (patch 1)
> - account tx bytes based on skb->len (patch 5)
> - new patches: changing mtu clean up, (re)init phy on resume
> - add net_ratelimit (patch 8)
> 
> All patches in series was tested on RTL8111/8168B

All applied, thank you.
