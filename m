From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/5] obsolete config in kernel source:
 USE_INTERNAL_TIMER
Date: Mon, 15 Mar 2010 16:05:55 -0700 (PDT)
Message-ID: <20100315.160555.196572499.davem@davemloft.net>
References: <201003112207.o2BM7rlU013495@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, siccegge@stud.informatik.uni-erlangen.de,
	roel.kluin@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937098Ab0COXFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 19:05:34 -0400
In-Reply-To: <201003112207.o2BM7rlU013495@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 11 Mar 2010 14:07:52 -0800

> From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
> 
> CONFIG_USE_INTERNAL_TIMER seems to be the remainings of some experiment. 
> It is explicitely #undef-ed as not working, only referenced from one
> source file and rather aged.
> 
> Hereby cleaning it from the kernel tree.
> 
> Signed-off-by: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
> Acked-by: Roel Kluin <roel.kluin@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
