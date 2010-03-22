From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] atm: Use kasprintf
Date: Sun, 21 Mar 2010 18:37:53 -0700 (PDT)
Message-ID: <20100321.183753.108798323.davem@davemloft.net>
References: <1268956106.2894.211.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753778Ab0CVBhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:37:31 -0400
In-Reply-To: <1268956106.2894.211.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Mar 2010 00:48:26 +0100

> Use kasprintf in atm_proc_dev_register()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
