From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: updates to syncookies - timestamps not needed any more (freebsd)
Date: Fri, 26 Jul 2013 05:56:24 -0700
Message-ID: <1374843384.3669.1.camel@edumazet-glaptop>
References: <20130708160421.GA9763@order.stressinduktion.org>
	 <20130711.165726.2168148122875413191.davem@davemloft.net>
	 <20130712084145.GJ27468@breakpoint.cc>
	 <1373637885.10804.7.camel@edumazet-glaptop>
	 <20130726064544.GC24247@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f49.google.com ([209.85.212.49]:46869 "EHLO
	mail-vb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325Ab3GZM43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 08:56:29 -0400
Received: by mail-vb0-f49.google.com with SMTP id w15so1171840vbb.8
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 05:56:27 -0700 (PDT)
In-Reply-To: <20130726064544.GC24247@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-26 at 08:45 +0200, Hannes Frederic Sowa wrote:
> Hi Eric!

Hi Hannes

> While cleaning up my patch directory I found this snippet. Perhaps you
> could send it for inclusion for net-next? Three nice additions: a similar
> change in tcp_ipv6.c and perhaps get rid of the warning messages printed
> to the console in case of syncookies == 2? A small update to ip-sysctl.txt
> wouldn't hurt either.
> 
> If you want to, I can take it and refresh it.

That would be a good idea, as I am currently traveling ;)

Thanks !
