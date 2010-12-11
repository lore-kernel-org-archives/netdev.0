From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] Using static const generally increases object text
 and decreases data size. It also generally decreases overall object size.
Date: Sat, 11 Dec 2010 11:48:04 -0800 (PST)
Message-ID: <20101211.114804.183050577.davem@davemloft.net>
References: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
	<1292031604-16628-4-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, ram.vepa@exar.com, joe@perches.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751725Ab0LKTrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 14:47:36 -0500
In-Reply-To: <1292031604-16628-4-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Fri, 10 Dec 2010 19:40:04 -0600

>    text	   data	    bss	    dec	    hex	filename
>  109387	    389	  24432	 134208	  20c40	drivers/net/s2io.o.old
>  109358	    389	  24432	 134179	  20c23	drivers/net/s2io.o.new
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Acked-by: Jon Mason <jon.mason@exar.com>

Applied, but I had to add an "s2io: " prefix to the subject line.

Thanks.
