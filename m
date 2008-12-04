From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next]simeth: Kill directly reference of netdev->priv
Date: Thu, 04 Dec 2008 15:06:31 -0800 (PST)
Message-ID: <20081204.150631.253228664.davem@davemloft.net>
References: <4937D362.4030500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48344
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751768AbYLDXGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 18:06:31 -0500
In-Reply-To: <4937D362.4030500@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 04 Dec 2008 20:56:02 +0800

> Simply replace netdev->priv with netdev_priv().
> 
> Not do compile test, because no ia64 box.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
