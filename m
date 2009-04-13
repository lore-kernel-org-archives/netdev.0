From: David Miller <davem@davemloft.net>
Subject: Re: at76c50x-usb: remove pointless conditional before kfree_skb()
Date: Mon, 13 Apr 2009 15:47:10 -0700 (PDT)
Message-ID: <20090413.154710.224376961.davem@davemloft.net>
References: <49DDAEE6.6020603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47025
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751482AbZDMWrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 18:47:19 -0400
In-Reply-To: <49DDAEE6.6020603@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 09 Apr 2009 16:16:38 +0800

> Remove pointless conditional before kfree_skb().
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
