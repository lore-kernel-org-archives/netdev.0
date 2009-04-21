From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unify the struct's name
Date: Tue, 21 Apr 2009 02:03:55 -0700 (PDT)
Message-ID: <20090421.020355.109580343.davem@davemloft.net>
References: <20090420140534.GB9119@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jianjun@zeuux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59206
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751185AbZDUJEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 05:04:04 -0400
In-Reply-To: <20090420140534.GB9119@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amos Kong <jianjun@zeuux.org>
Date: Mon, 20 Apr 2009 22:05:34 +0800

> 
> unify the struct's name of "struct rtl8139_private *np" to "struct rtl8139_private *tp"
> 
> most of them like this:
> struct rtl8139_private *tp = netdev_priv(dev);
> 
> Signed-off-by: Amos Kong <jianjun@zeuux.org>

Applied, thanks.
