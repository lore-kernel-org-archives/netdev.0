From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: this_cpu_xxx conversions
Date: Mon, 19 Jul 2010 15:13:27 -0700 (PDT)
Message-ID: <20100719.151327.135949713.davem@davemloft.net>
References: <1279572529.2458.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966620Ab0GSWNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 18:13:11 -0400
In-Reply-To: <1279572529.2458.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Jul 2010 22:48:49 +0200

> Use modern this_cpu_xxx() api, saving few bytes on x86
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
