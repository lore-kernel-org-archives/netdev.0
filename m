From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Fri, 29 Oct 2010 15:21:56 -0700 (PDT)
Message-ID: <20101029.152156.226762211.davem@davemloft.net>
References: <20101026.122022.241452738.davem@davemloft.net>
	<1288121422.2652.14.camel@edumazet-laptop>
	<4CCB3F94.20709@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ebiederm@xmission.com,
	netdev@vger.kernel.org
To: daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49262
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761850Ab0J2WVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 18:21:33 -0400
In-Reply-To: <4CCB3F94.20709@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel.lezcano@free.fr>
Date: Fri, 29 Oct 2010 23:41:40 +0200

> do you plan to send another version of this patch ? Or can I test it
> as it is ?  Without removing a network device, I can check the
> routine, no ?

I'm backlogged with the current merge window work and fixing bugs,
so feel free to test what I posted if you have the time.

I'll post an updated version when time permits.

Thanks.
