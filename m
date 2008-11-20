From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice ppp: Convert directly reference of
 netdev->priv
Date: Thu, 20 Nov 2008 04:24:25 -0800 (PST)
Message-ID: <20081120.042425.17642616.davem@davemloft.net>
References: <49252ADD.9020104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751663AbYKTMYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:24:25 -0500
In-Reply-To: <49252ADD.9020104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 20 Nov 2008 17:16:13 +0800

> 1. Use netdev_priv(dev) to replace dev->priv.
> 2. Alloc netdev's private data by alloc_netdev().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
