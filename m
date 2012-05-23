From: Sergio Correia <lists@uece.net>
Subject: Re: WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
Date: Wed, 23 May 2012 12:56:39 -0300
Message-ID: <CAJyhjX02wjsVE2pM26a+7xTrAJwvLZo0UL-W6h8zMKEiC5qTug@mail.gmail.com>
References: <CAJyhjX22Vna=TwuhD-FqyoXEd9D8wq_VdHbAAWwmqO1hZ34FRA@mail.gmail.com>
 <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com>
 <1337697203.3361.190.camel@edumazet-glaptop> <CAJyhjX2f_XFgVZpS1hLy5CWKY7eYA5MzQSHsfRgc40-2Rxztkw@mail.gmail.com>
 <1337785681.3361.2923.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:41810 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876Ab2EWP47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 11:56:59 -0400
Received: by obbtb18 with SMTP id tb18so11221875obb.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 08:56:59 -0700 (PDT)
In-Reply-To: <1337785681.3361.2923.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 23, 2012 at 12:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-05-22 at 11:47 -0300, Sergio Correia wrote:
>> Hi Eric,
> ...
>> Yes, it's an Atheros AR9285 adapter.
>> This morning I did a make mrproper before rebuilding the kernel
>> (should I always do that?), but the warning has just appeared again.
>
> OK, I am taking a look at this problem, thanks.
>

Thanks. Let me know if you need additional info. As of now, my dmesg
basically shows only those warnings.
