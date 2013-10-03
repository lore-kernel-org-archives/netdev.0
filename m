From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: shrink tcp6_timewait_sock by one cache
 line
Date: Thu, 03 Oct 2013 14:45:30 -0700
Message-ID: <1380836730.19002.237.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380829642.19002.225.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003.160252.2071364130742864278.davem@davemloft.net>
	 <1380835645.19002.236.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003.174357.89621984330679119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:56016 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755663Ab3JCVpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:45:32 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so3013342pbc.7
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 14:45:31 -0700 (PDT)
In-Reply-To: <20131003.174357.89621984330679119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 17:43 -0400, David Miller wrote:

> Looks great, applied, thanks Eric.

Thanks for your patience ;)
