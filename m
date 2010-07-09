From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] ll_temac: fix memory leak
Date: Thu, 08 Jul 2010 23:43:30 -0700 (PDT)
Message-ID: <20100708.234330.02291854.davem@davemloft.net>
References: <1278591006-3156-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, john.linn@xilinx.com,
	grant.likely@secretlab.ca, jpirko@redhat.com,
	brian.hill@xilinx.com, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35812
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751337Ab0GIGnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:43:16 -0400
In-Reply-To: <1278591006-3156-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Thu,  8 Jul 2010 16:10:03 +0400

> If of_iomap() or irq_of_parse_and_map() fail then np must be freed.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied, thanks.
