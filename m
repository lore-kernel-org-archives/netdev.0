From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ipv6: use list_move instead of
 list_del/list_add
Date: Sat, 30 Jul 2016 20:42:25 -0700 (PDT)
Message-ID: <20160730.204225.1907065077351128281.davem@davemloft.net>
References: <1469722743-15317-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbcGaDm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 23:42:27 -0400
In-Reply-To: <1469722743-15317-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 28 Jul 2016 16:19:03 +0000

> Using list_move() instead of list_del() + list_add().
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
