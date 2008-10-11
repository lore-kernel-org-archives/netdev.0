From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: pkt_sched: cls_u32: Fix locking in u32_delete()
Date: Sun, 12 Oct 2008 00:04:18 +0200
Message-ID: <20081011220418.GA2540@ami.dom.local>
References: <20081011111711.GA2808@ami.dom.local> <E1KofAk-0001uJ-0q@gondolin.me.apana.org.au> <20081011.122400.51934908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, m0sia@plotinka.ru,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:56965 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620AbYJKWDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 18:03:33 -0400
Received: by fk-out-0910.google.com with SMTP id 18so988104fkq.5
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2008 15:03:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081011.122400.51934908.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2008 at 12:24:00PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 11 Oct 2008 22:10:22 +0800
...
> But hey, we could be missing something here, so I'd be happy to
> hear that Jarek can still see some hole here :)  Because it is true
> that we have seen some weird crashes still and u32 seems common
> amongst those report.
> 

Yes, you could be missing something, but I've forgotten what, because
when I found this I was much younger and brighter... and alas now I've
a busy weekend, so let it wait until monday.

Thanks you both for looking at this,
Jarek P.
