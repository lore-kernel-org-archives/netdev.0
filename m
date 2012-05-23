From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
Date: Wed, 23 May 2012 17:08:01 +0200
Message-ID: <1337785681.3361.2923.camel@edumazet-glaptop>
References: <CAJyhjX22Vna=TwuhD-FqyoXEd9D8wq_VdHbAAWwmqO1hZ34FRA@mail.gmail.com>
	 <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com>
	 <1337697203.3361.190.camel@edumazet-glaptop>
	 <CAJyhjX2f_XFgVZpS1hLy5CWKY7eYA5MzQSHsfRgc40-2Rxztkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergio Correia <lists@uece.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61444 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753771Ab2EWPIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 11:08:15 -0400
Received: by eeit10 with SMTP id t10so2128586eei.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 08:08:14 -0700 (PDT)
In-Reply-To: <CAJyhjX2f_XFgVZpS1hLy5CWKY7eYA5MzQSHsfRgc40-2Rxztkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 11:47 -0300, Sergio Correia wrote:
> Hi Eric,
...
> Yes, it's an Atheros AR9285 adapter.
> This morning I did a make mrproper before rebuilding the kernel
> (should I always do that?), but the warning has just appeared again.

OK, I am taking a look at this problem, thanks.
