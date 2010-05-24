From: David Miller <davem@davemloft.net>
Subject: Re: [patch] pppoe: uninitialized variable in pppoe_flush_dev()
Date: Sun, 23 May 2010 23:50:16 -0700 (PDT)
Message-ID: <20100523.235016.15711522.davem@davemloft.net>
References: <20100522202534.GO22515@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@earthlink.net, eric.dumazet@gmail.com, jpirko@redhat.com,
	denys@visp.net.lb, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755808Ab0EXGuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:50:06 -0400
In-Reply-To: <20100522202534.GO22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 22 May 2010 22:27:48 +0200

> This assignment got deleted along with the checks by mistake.  This
> comes from:  8753d29fd "pppoe: remove unnecessary checks in
> pppoe_flush_dev"
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
