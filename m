From: David Miller <davem@davemloft.net>
Subject: Re: [Patch]8139too: remove unnecessary cast of ioread32()'s return
 value
Date: Mon, 31 May 2010 00:33:39 -0700 (PDT)
Message-ID: <20100531.003339.242155242.davem@davemloft.net>
References: <20100530122213.GB1146@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: junchangwang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753516Ab0EaHd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 03:33:29 -0400
In-Reply-To: <20100530122213.GB1146@host-a-55.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junchang Wang <junchangwang@gmail.com>
Date: Sun, 30 May 2010 20:22:14 +0800

> ioread32() returns a 32-bit integer on all platforms.
> There is no need to cast its return value.
> 
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>

Applied.
