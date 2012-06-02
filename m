From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network hangs on current git kernel
Date: Sat, 02 Jun 2012 11:50:10 +0200
Message-ID: <1338630610.2760.1695.camel@edumazet-glaptop>
References: <20120602082503.GC329@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36726 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933858Ab2FBJuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 05:50:15 -0400
Received: by bkcji2 with SMTP id ji2so2490818bkc.19
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2012 02:50:14 -0700 (PDT)
In-Reply-To: <20120602082503.GC329@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-02 at 10:25 +0200, Markus Trippelsdorf wrote:
> I'm running the latest git kernel 3.4.0-09820-g86c47b7 and see periodic
> network "hangs" on my machine.
> 
> These hangs mostly occur when I read nntp news articles. Every once in a
> while the nntp client seems to take forever to fetch an article. During
> these hangs I see packet losses:

> --- heise.de ping statistics ---
> 46 packets transmitted, 32 received, 30% packet loss, time 45101ms
> rtt min/avg/max/mdev = 21.613/23.021/32.210/1.924 ms
> 
> Sorry, if this all sounds somewhat vague. I will try to record a sysrq-w dump
> in the future.
> 

For sure... its a bit vague.

Maybe tell us what NIC it is, that sort of things...
