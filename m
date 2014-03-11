From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 net-next 1/3] filter: add Extended BPF interpreter
 and converter
Date: Mon, 10 Mar 2014 22:24:49 -0400 (EDT)
Message-ID: <20140310.222449.561233409099006984.davem@davemloft.net>
References: <1394431444-6987-2-git-send-email-ast@plumgrid.com>
	<20140310.215104.2095195123238829635.davem@davemloft.net>
	<CA+55aFx7rdm9DGOTTgAKTHNkdfrvQYhT9PRs5MhUPr1gQzWEgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, dborkman@redhat.com, mingo@kernel.org,
	wad@chromium.org, rostedt@goodmis.org, a.p.zijlstra@chello.nl,
	hpa@zytor.com, hagen@jauu.net, jesse@nicira.com,
	tglx@linutronix.de, edumazet@google.com, akpm@linux-foundation.org,
	fweisbec@gmail.com, acme@infradead.org, penberg@iki.fi,
	arjan@infradead.org, hch@infradead.org, xemul@parallels.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx7rdm9DGOTTgAKTHNkdfrvQYhT9PRs5MhUPr1gQzWEgA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Mar 2014 19:02:18 -0700

> I would generally suggest that people only use "bool" for function
> return types, and absolutely nothing else. Seriously.

I think it makes sense for function arguments too.
