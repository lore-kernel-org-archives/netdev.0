From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/8] hysdn: no longer broken on SMP
Date: Wed, 14 May 2008 16:41:47 -0700 (PDT)
Message-ID: <20080514.164147.104235051.davem@davemloft.net>
References: <200805142319.m4ENJigG026563@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de,
	mark.asselstine@windriver.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754996AbYENXlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:41:52 -0400
In-Reply-To: <200805142319.m4ENJigG026563@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 14 May 2008 16:19:44 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> With the cli/sti code sorted out we think this driver is OK for use on SMP
> systems.
> 
> Acked-by: Mark Asselstine <mark.asselstine@windriver.com>
> Acked-by: Karsten Keil <kkeil@suse.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David S. Miller <davem@davemloft.net>
