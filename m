From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/qlge: Remove duplicated initial
 DUMP_ macro entries
Date: Wed, 21 Jul 2010 14:43:33 -0700 (PDT)
Message-ID: <20100721.144333.82796756.davem@davemloft.net>
References: <1279576149.5434.59.camel@Joe-Laptop.home>
	<20100721.135800.43444396.davem@davemloft.net>
	<1279747141.1909.22.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53042
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757186Ab0GUVnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 17:43:17 -0400
In-Reply-To: <1279747141.1909.22.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 21 Jul 2010 14:19:01 -0700

> There are a couple of errors in the previous patch.
> Two of the first DUMP_<foo> entries are duplicated.
> Sorry, bad use of emacs macros...
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Since I didn't push your original change out yet, I'll just add this
to the original commit.

Thanks!
