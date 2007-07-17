From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7][ATM]: Replacing kmalloc/memset combination with
 kzalloc.
Date: Mon, 16 Jul 2007 18:31:01 -0700 (PDT)
Message-ID: <20070716.183101.35508853.davem@davemloft.net>
References: <200707161629.l6GGTh3U009254@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752232AbXGQBa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:30:59 -0400
In-Reply-To: <200707161629.l6GGTh3U009254@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Mon, 16 Jul 2007 12:29:43 -0400

> [ATM]: Replacing kmalloc/memset combination with kzalloc.
> 
> Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
> Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

I had to apply this patch by hand because sch_atm.c has
changed considerably in the current tree.

But applied nonetheless, thanks.
