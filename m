From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nets: remove two duplicated #include
Date: Mon, 03 Nov 2008 18:23:19 -0800 (PST)
Message-ID: <20081103.182319.103857163.davem@davemloft.net>
References: <20081103121908.GA24634@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jianjun@zeuux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33644
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbYKDCXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 21:23:43 -0500
In-Reply-To: <20081103121908.GA24634@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianjun Kong <jianjun@zeuux.org>
Date: Mon, 3 Nov 2008 20:19:08 +0800

> 
> [PATCH] nets: remove two duplicated #include
> 
> Removed duplicated #include <rdma/ib_verbs.h> in net/9p/trans_rdma.c
> 		and  #include <linux/thread_info.h> in net/socket.c
> 
> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>

Applied, thank you.
