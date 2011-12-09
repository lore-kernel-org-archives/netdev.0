From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sock_diag: off by one checks
Date: Thu, 08 Dec 2011 19:54:30 -0500 (EST)
Message-ID: <20111208.195430.857245382290814411.davem@davemloft.net>
References: <20111208064938.GB16735@elgon.mountain>
	<4EE07E6B.5050608@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab1LIAyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 19:54:37 -0500
In-Reply-To: <4EE07E6B.5050608@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 08 Dec 2011 13:07:55 +0400

> On 12/08/2011 10:49 AM, Dan Carpenter wrote:
>> These tests are off by one because sock_diag_handlers[] only has AF_MAX
>> elements.
> 
> Oops :(
> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
