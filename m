From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: drivers/net: include/net: Remove
 unnecessary semicolons
Date: Sun, 05 Jun 2011 14:34:36 -0700 (PDT)
Message-ID: <20110605.143436.1278867543091833598.davem@davemloft.net>
References: <cover.1307137351.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756129Ab1FEVei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:34:38 -0400
In-Reply-To: <cover.1307137351.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri,  3 Jun 2011 14:51:18 -0700

> Done via perl script:
 ...
> Joe Perches (3):
>   net: Remove unnecessary semicolons
>   drivers/net: Remove unnecessary semicolons
>   include/net: Remove unnecessary semicolons

All applied, thanks Joe.

I remember earlier in my programming that I was robotically
putting that trailing semicolon at the end of switch statements
:-)
