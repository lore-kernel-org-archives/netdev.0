From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/tcp_ipv6.c: fix sparse warnings
Date: Tue, 28 Apr 2009 02:08:24 -0700 (PDT)
Message-ID: <20090428.020824.12093588.davem@davemloft.net>
References: <BD79186B4FD85F4B8E60E381CAEE19090165F12C@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57406
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754081AbZD1JIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 05:08:31 -0400
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090165F12C@mi8nycmail19.Mi8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Date: Wed, 22 Apr 2009 20:35:39 -0400

> Fix the following sparse warnings in net/ipv6/tcp_ipv6.c.
> 
>   warning: symbol 'tcp6_gro_receive' was not declared. Should it be static?
>   warning: symbol 'tcp6_gro_complete' was not declared. Should it be static?
> 
> Both symbols are exported but not referenced anywhere outside of
> this source file. Remove the exports and make the functions static.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

1) Please post networking patches with netdev@vger.kernel.org
   at least CC:'d

2) Your email client corrupted this patch, making it not apply
   properly.

Please fix these details up and resubmit your patch, thanks!
