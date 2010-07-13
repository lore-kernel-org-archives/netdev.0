From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc35815: fix iomap leak
Date: Mon, 12 Jul 2010 20:33:27 -0700 (PDT)
Message-ID: <20100712.203327.135522958.davem@davemloft.net>
References: <1278756199-4636-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, anemo@mba.ocn.ne.jp,
	jpirko@redhat.com, eric.dumazet@gmail.com, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349Ab0GMDdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:33:12 -0400
In-Reply-To: <1278756199-4636-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Sat, 10 Jul 2010 14:03:18 +0400

> If tc35815_init_one() fails we must unmap mapped regions.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
