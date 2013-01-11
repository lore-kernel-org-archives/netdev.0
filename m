From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] gianfar: use more portable i/o accessors
Date: Fri, 11 Jan 2013 15:59:27 -0800 (PST)
Message-ID: <20130111.155927.815869016885203345.davem@davemloft.net>
References: <20130111161821.d62a0a60ee8d1005fb14b4d5@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kim.phillips@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255Ab3AKX72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 18:59:28 -0500
In-Reply-To: <20130111161821.d62a0a60ee8d1005fb14b4d5@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Phillips <kim.phillips@freescale.com>
Date: Fri, 11 Jan 2013 16:18:21 -0600

> in/out_be32 accessors are Power arch centric whereas
> ioread/writebe32 are available in other arches.  Also, unlike
> in/out_be32, ioread/writebe32 expect non-volatile address arguments.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>

Applied.
