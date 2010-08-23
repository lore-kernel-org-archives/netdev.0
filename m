From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
	skb_copy_and_csum_dev
Date: Mon, 23 Aug 2010 13:10:56 +0000
Message-ID: <20100823131056.GA19160@ff.dom.local>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg> <20100820193835.GA6025@del.dom.local> <20100821074742.GA2367@del.dom.local> <1282377058.2636.12.camel@edumazet-laptop> <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg> <20100823124736.GA16966@ff.dom.local> <1282568443.2486.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50056 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab0HWNLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 09:11:03 -0400
Received: by fxm13 with SMTP id 13so2876844fxm.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 06:11:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1282568443.2486.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 03:00:43PM +0200, Eric Dumazet wrote:
...
> I was about to suggest a similar patch ;)
> 
> Also prints skb->csum_offset and skb->len if possible

Feel free to send it: I'm a bit in hurry now...

Jarek P.
