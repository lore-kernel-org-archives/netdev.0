From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] sfc: additional virtual function
 =?utf-8?B?c3VwcG9ydOKAiw==?=
Date: Wed, 23 Dec 2015 22:06:57 -0500 (EST)
Message-ID: <20151223.220657.581690504804855533.davem@davemloft.net>
References: <5674274C.4020606@solarflare.com>
	<567A6170.6010104@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40573 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975AbbLXDG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 22:06:58 -0500
In-Reply-To: <567A6170.6010104@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Wed, 23 Dec 2015 08:55:12 +0000

> This introduces the client side of a mechanism to defer authorisation of
> operations, for example multicast subscription. Although primarily aimed at
> SRIOV VFs this can also apply to unprivileged PFs.
> 
> Also handle reboot ordering corner cases better and reduce the level of some
> logging.
> 
> v2: remove #ifdef DEBUG around new WARN_ON in mcdi.c.

Series applied, thanks.
