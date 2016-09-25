From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] rxrpc: Implement slow-start and other bits
Date: Sun, 25 Sep 2016 05:56:32 -0400 (EDT)
Message-ID: <20160925.055632.20945443198215413.davem@davemloft.net>
References: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Sun, 25 Sep 2016 00:24:56 +0100

> This set of patches implements the RxRPC slow-start feature for AF_RXRPC to
> improve performance and handling of occasional packet loss.  This is more or
> less the same as TCP slow start [RFC 5681].  Firstly, there are some ACK
> generation improvements:
 ...
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160924

Pulled, thanks David.
