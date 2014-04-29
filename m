From: Florian Westphal <fw@strlen.de>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by ipv4:
 fix path MTU discovery with connection tracking)
Date: Tue, 29 Apr 2014 22:13:52 +0200
Message-ID: <20140429201352.GQ31953@breakpoint.cc>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
 <20140429143324.GB12781@macbook.localnet>
 <1398782535.4033.11.camel@sakura.staff.proxad.net>
 <20140429144513.GA12969@macbook.localnet>
 <1398785021.4033.19.camel@sakura.staff.proxad.net>
 <1398785841.29914.146.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mbizon@freebox.fr, Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50686 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751878AbaD2UN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 16:13:57 -0400
Content-Disposition: inline
In-Reply-To: <1398785841.29914.146.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Hmm... maybe its finally time to rename local_df to ignore_df, as
> Maze suggested some time ago ...

Yes please.
