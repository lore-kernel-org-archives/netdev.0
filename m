From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice wanrouter: Convert directly
 reference of netdev->priv
Date: Thu, 20 Nov 2008 04:26:27 -0800 (PST)
Message-ID: <20081120.042627.14445595.davem@davemloft.net>
References: <49252AE1.8000609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58440
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754900AbYKTM01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:26:27 -0500
In-Reply-To: <49252AE1.8000609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 20 Nov 2008 17:16:17 +0800

> 1. Make device driver to allocate memory for netdev.
> 2. Convert all directly reference of netdev->priv to netdev_priv().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
