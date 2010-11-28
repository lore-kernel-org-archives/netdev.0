From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: Don't leak others' openreq-s in proc
Date: Sat, 27 Nov 2010 22:58:41 -0800 (PST)
Message-ID: <20101127.225841.59666859.davem@davemloft.net>
References: <4CEA6F74.6010107@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751704Ab0K1G6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 01:58:15 -0500
In-Reply-To: <4CEA6F74.6010107@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 22 Nov 2010 16:26:12 +0300

> The /proc/net/tcp leaks openreq sockets from other namespaces.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied to net-2.6, thanks!
