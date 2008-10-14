From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: mib6 section fixlet
Date: Mon, 13 Oct 2008 18:54:23 -0700 (PDT)
Message-ID: <20081013.185423.128560414.davem@davemloft.net>
References: <20081013082755.GB19572@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34778
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752138AbYJNByr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 21:54:47 -0400
In-Reply-To: <20081013082755.GB19572@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 13 Oct 2008 12:27:55 +0400

>   LD      net/ipv6/ipv6.o
> WARNING: net/ipv6/ipv6.o(.text+0xd8): Section mismatch in reference from the function inet6_net_init() to the function .init.text:ipv6_init_mibs()
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks.
