From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove COMPAT_NET_DEV_OPS
Date: Mon, 25 May 2009 14:43:46 -0700 (PDT)
Message-ID: <20090525.144346.141244330.davem@davemloft.net>
References: <1243088259-16482-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54347
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752463AbZEYVnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 17:43:47 -0400
In-Reply-To: <1243088259-16482-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Sat, 23 May 2009 18:17:39 +0400

> All drivers are already converted to new net_device_ops API
> and nobody uses old API anymore.
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

With great pleasure I've applied this and will push it out to
net-next-2.6 after some quick build testing.

Thanks!
