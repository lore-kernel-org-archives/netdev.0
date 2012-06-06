From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Remove casts to same type
Date: Wed, 06 Jun 2012 09:33:08 -0700 (PDT)
Message-ID: <20120606.093308.298888154611470462.davem@davemloft.net>
References: <cover.1338849364.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab2FFQdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 12:33:09 -0400
In-Reply-To: <cover.1338849364.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon,  4 Jun 2012 15:44:15 -0700

> Adding casts of objects to the same type is unnecessary
> and confusing for a human reader.
> 
> Remove them via coccinelle script.
> 
> No additional sparse warnings are emitted.
> 
> Joe Perches (3):
>   ethernet: Remove casts to same type
>   wireless: Remove casts to same type
>   drivers: net: Remove casts to same type

All applied, thanks Joe.
