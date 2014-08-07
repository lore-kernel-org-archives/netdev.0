From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Remove typedefs pcnet_dev_t and hw_info_t
Date: Thu, 07 Aug 2014 16:06:52 -0700 (PDT)
Message-ID: <20140807.160652.1955607781047860694.davem@davemloft.net>
References: <20140807204039.GA21415@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tedheadster@gmail.com, paul.gortmaker@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbaHGXGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:06:54 -0400
In-Reply-To: <20140807204039.GA21415@himangi-Dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 8 Aug 2014 02:10:39 +0530

> The Linux kernel coding style guidelines suggest not using typedefs
> for structure types. This patch gets rid of the typedefs for pcnet_dev_t
> and hw_info_t. Also, the name of the structs is changed to drop the _t,
> to make the name look less typedef-like.
> 
> The following Coccinelle semantic patch detects the cases:
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
