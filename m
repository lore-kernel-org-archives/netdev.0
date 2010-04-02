From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] gen_estimator: deadlock fix
Date: Thu, 01 Apr 2010 18:44:47 -0700 (PDT)
Message-ID: <20100401.184447.11576491.davem@davemloft.net>
References: <1270055164.2103.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42602
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759122Ab0DBBoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:44:46 -0400
In-Reply-To: <1270055164.2103.99.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 31 Mar 2010 19:06:04 +0200

> David, feel free to apply following to net-next, as I believe
> probability to get this deadlock is close to 0.
 ...
> [PATCH] gen_estimator: deadlock fix

Applied.
