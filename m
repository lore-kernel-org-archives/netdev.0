From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] netdevice pc300: Convert directly
 reference of netdev->priv
Date: Fri, 21 Nov 2008 16:35:50 -0800 (PST)
Message-ID: <20081121.163550.44783852.davem@davemloft.net>
References: <4926793E.3080208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, khc@pm.waw.pl, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753455AbYKVAfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:35:51 -0500
In-Reply-To: <4926793E.3080208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 21 Nov 2008 17:02:54 +0800

> netdev's private data should be hdlc.
> pc300dev_t is the private data of hdlc.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
