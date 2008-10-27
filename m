From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
 addresses
Date: Mon, 27 Oct 2008 15:47:36 -0700 (PDT)
Message-ID: <20081027.154736.178482850.davem@davemloft.net>
References: <1225124904.5440.1.camel@brick>
	<20081027.123805.134354592.davem@davemloft.net>
	<1225137542.5396.10.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33224
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750908AbYJ0Wr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 18:47:59 -0400
In-Reply-To: <1225137542.5396.10.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 27 Oct 2008 12:59:02 -0700

> Add format specifiers for printing out six colon-separated bytes:
> 
> MAC addresses (%pM):
> xx:xx:xx:xx:xx:xx
> 
> %#pM is also supported and omits the colon separators.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks.
