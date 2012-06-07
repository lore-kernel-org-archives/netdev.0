From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Thu, 07 Jun 2012 16:25:44 +0200
Message-ID: <1339079144.5083.15.camel@edumazet-glaptop>
References: <jqo7op$t6f$1@dough.gmane.org>
	 <1339008142.26966.40.camel@edumazet-glaptop> <jqo9a6$ah6$1@dough.gmane.org>
	 <20120606.120247.1618312724057709285.davem@davemloft.net>
	 <jqqa1b$kug$1@dough.gmane.org> <1339077710.5083.12.camel@edumazet-glaptop>
	 <jqqd4k$i2c$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Grant Edwards <grant.b.edwards@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42574 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760760Ab2FGOZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 10:25:48 -0400
Received: by eeit10 with SMTP id t10so257579eei.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 07:25:47 -0700 (PDT)
In-Reply-To: <jqqd4k$i2c$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-07 at 14:16 +0000, Grant Edwards wrote:

> I was merely pointing out that the API was indeed documented that way.


Good, you are right and we were wrong.

Hopefully you can still use linux-2
