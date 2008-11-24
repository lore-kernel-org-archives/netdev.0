From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice sbni: Convert directly reference of
 netdev->priv
Date: Mon, 24 Nov 2008 14:52:25 -0800 (PST)
Message-ID: <20081124.145225.150446015.davem@davemloft.net>
References: <492A2611.804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, khc@pm.waw.pl
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753233AbYKXWwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 17:52:25 -0500
In-Reply-To: <492A2611.804@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 24 Nov 2008 11:57:05 +0800

> 1. convert netdev->priv to netdev_priv().
> 2. make sbni_pci_probe() be static.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
