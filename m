From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-procfs: Use vsnprintf extension %phN
Date: Sun, 04 Jun 2017 19:53:11 -0400 (EDT)
Message-ID: <20170604.195311.2285139648179351578.davem@davemloft.net>
References: <41a53a84b6332651a9c562a4f834ba964c1810e9.1496396274.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751162AbdFDXxN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 19:53:13 -0400
In-Reply-To: <41a53a84b6332651a9c562a4f834ba964c1810e9.1496396274.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri,  2 Jun 2017 02:40:44 -0700

> Save a bit of code by using the kernel extension.
> 
> $ size net/core/net-procfs.o*
>    text	   data	    bss	    dec	    hex	filename
>    3701	    120	      0	   3821	    eed	net/core/net-procfs.o.new
>    3764	    120	      0	   3884	    f2c	net/core/net-procfs.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
