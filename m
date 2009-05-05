From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lasi_82596: fix printk format warning
Date: Tue, 05 May 2009 12:30:45 -0700 (PDT)
Message-ID: <20090505.123045.95429787.davem@davemloft.net>
References: <1241521412-16190-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55296
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757013AbZEETau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 15:30:50 -0400
In-Reply-To: <1241521412-16190-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Tue,  5 May 2009 15:03:32 +0400

> drivers/net/lasi_82596.c:164: warning: format '%lx' expects type
> 	'long unsigned int', but argument 3 has type 'resource_size_t'
> drivers/net/lasi_82596.c:169: warning: format '%lx' expects type
> 	'long unsigned int', but argument 2 has type 'resource_size_t'
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

APplied to net-next-2.6
