From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] tc35815: Fix an usage of streaming DMA API.
Date: Thu, 15 Mar 2007 00:11:29 +0900 (JST)
Message-ID: <20070315.001129.126139947.anemo@mba.ocn.ne.jp>
References: <20070313120418.554a3a43@freekitty>
	<20070314.100557.33857330.nemoto@toshiba-tops.co.jp>
	<45F7C797.4030509@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org, netdev@vger.kernel.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:62862 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161337AbXCNPLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 11:11:34 -0400
In-Reply-To: <45F7C797.4030509@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Mar 2007 05:59:51 -0400, Jeff Garzik <jeff@garzik.org> wrote:
> > OK, Jeff, should I send a revised patch dropping this line?
> 
> Nah, there's no need to reject the patch on that basis.
> 
> You should send an additional patch, on top of all others you sent 
> recently, that completely removes the entire changelog from the driver 
> source code :)

OK, Done :)
---
Atsushi Nemoto
