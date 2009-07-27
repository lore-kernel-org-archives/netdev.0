From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: export xfrm garbage collector thresholds via
 sysctl
Date: Mon, 27 Jul 2009 13:10:15 -0700 (PDT)
Message-ID: <20090727.131015.138045613.davem@davemloft.net>
References: <20090727193625.GD15823@hmsreliant.think-freely.org>
	<20090727.124011.05728493.davem@davemloft.net>
	<7E46FEB5-E422-45B2-9D68-010DD7C23B78@nall.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: joe@nall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754603AbZG0UKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 16:10:09 -0400
In-Reply-To: <7E46FEB5-E422-45B2-9D68-010DD7C23B78@nall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Nall <joe@nall.com>
Date: Mon, 27 Jul 2009 15:02:20 -0500

> The problem was seen serving TCP connections over IPSec when the
> server (a 24 core machine w 32GB RAM) and the IPSec host were the same
> (transport not tunnel).

Aha, thanks for the clarification, that makes a lot more sense.
