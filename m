From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/llc: storing negative error codes in unsigned short
Date: Thu, 16 Sep 2010 22:39:35 -0700 (PDT)
Message-ID: <20100916.223935.190380307.davem@davemloft.net>
References: <20100916181155.GB7867@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754046Ab0IQFjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 01:39:16 -0400
In-Reply-To: <20100916181155.GB7867@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 16 Sep 2010 20:12:55 +0200

> If the alloc_skb() fails then we return 65431 instead of -ENOBUFS
> (-105). 
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
