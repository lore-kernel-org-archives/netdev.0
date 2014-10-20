From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Sun, 19 Oct 2014 21:03:14 -0400 (EDT)
Message-ID: <20141019.210314.1388340101577924200.davem@davemloft.net>
References: <20141019.132314.264021750039480460.davem@davemloft.net>
	<CA+55aFz4UdVbZKPKwkesj0=1Yu7jLDP3Q3-jwe45b7gRU+0rog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFz4UdVbZKPKwkesj0=1Yu7jLDP3Q3-jwe45b7gRU+0rog@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 19 Oct 2014 17:32:15 -0700

> Looks like the module license issue was just overlooked when moving
> the code out in commit c8d7b98bec43 ("netfilter: move nf_send_resetX()
> code to nf_reject_ipvX modules").

I think Pablo has a patch pending to address this, and indeed he does:

	http://marc.info/?l=linux-netdev&m=141293491712312&w=2

Pablo please push this to me soon, thanks.
