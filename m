From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: e1000e: possible reggresion?
Date: Fri, 21 Aug 2015 06:38:05 -0700
Message-ID: <1440164285.6610.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <665F7BF9-6041-4E7D-8A37-1B87770F9FAA@gmail.com>
	 <1440102551.6610.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMGsXDQa=NR3qUd4xJpSNcS2myF+n9P_A-zvyKQYjjE5XN2zCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tomas Papan <tomas.papan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34755 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbHUNiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 09:38:08 -0400
Received: by padfo6 with SMTP id fo6so7578136pad.1
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 06:38:07 -0700 (PDT)
In-Reply-To: <CAMGsXDQa=NR3qUd4xJpSNcS2myF+n9P_A-zvyKQYjjE5XN2zCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-21 at 12:48 +0200, Tomas Papan wrote:
> Hi Eric,
> 
> It was probalby it. Uptime 5+ hours and no problem.
> 
> Thanks for the hint, I was compiling linus tree yesterday around 12:00 UTC,
> your change was added later.

Sure, let me know if you have any problems.

A timer fix was also queued, not yet in Linus tree.

https://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/commit/?id=d0023a1448abdcc892b8bca631e74bb1888efd02
