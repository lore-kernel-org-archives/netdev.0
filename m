From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] epoll: add EPOLLEXCLUSIVE support
Date: Tue, 14 Feb 2012 22:38:23 +0100
Message-ID: <20120214213823.GB6097@nuttenaction>
References: <1329252484-6309-1-git-send-email-hagen@jauu.net>
 <1329253575.2555.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Davide Libenzi <davidel@xmailserver.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1329253575.2555.16.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Eric Dumazet | 2012-02-14 22:06:15 [+0100]:

>Seems pretty good to me.
>
>Do you have some performance numbers to share ?

No, but I did some tests with one of my network performance tools. I imagine
that I can *construct* test-cases and add some 'perf stat cs:u' statistics.
IMHO it is not fair to present some artificial tunned performance numbers.
There are use-cases where EPOLLEXCLUSIVE can be really helpfull, yes I think
that this flag SHOULD be a userspace default. ;-)

Hagen
