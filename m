From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/15] ROUND_UP macro cleanup in
 drivers/net/ppp_generic.c
Date: Thu, 26 Apr 2007 01:02:03 -0700 (PDT)
Message-ID: <20070426.010203.89038573.davem@davemloft.net>
References: <200704260727.l3Q7RP04023958@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, milindchoudhary@gmail.com, paulus@samba.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43463
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933638AbXDZIBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:01:55 -0400
In-Reply-To: <200704260727.l3Q7RP04023958@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Thu, 26 Apr 2007 00:27:25 -0700

> From: Milind Arun Choudhary <milindchoudhary@gmail.com>
> 
> ROUND_UP macro cleanup use DIV_ROUND_UP
> 
> Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Acked-by: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
