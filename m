From: David Miller <davem@davemloft.net>
Subject: Re: [patch 07/15] iucv: fix compilation on s390-up
Date: Thu, 26 Apr 2007 01:02:59 -0700 (PDT)
Message-ID: <20070426.010259.95895025.davem@davemloft.net>
References: <200704260727.l3Q7RQWQ023961@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adobriyan@gmail.com,
	heiko.carstens@de.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43467
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933372AbXDZICw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:02:52 -0400
In-Reply-To: <200704260727.l3Q7RQWQ023961@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Thu, 26 Apr 2007 00:27:26 -0700

> From: Alexey Dobriyan <adobriyan@gmail.com>
> 
>   CC [M]  net/iucv/iucv.o
> net/iucv/iucv.c: In function 'iucv_init':
> net/iucv/iucv.c:1556: error: 'iucv_cpu_notifier' undeclared (first use in this function)
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
