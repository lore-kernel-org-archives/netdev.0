From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/5] rxrpc: fix last_call processing
Date: Wed, 31 Aug 2016 21:58:24 +0100
Message-ID: <1260.1472677104@warthog.procyon.org.uk>
References: <5882481.rHsi0mzMry@wuerfel> <20160826152546.604384-4-arnd@arndb.de> <20160826152546.604384-1-arnd@arndb.de> <13158.1472373737@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5882481.rHsi0mzMry@wuerfel>
Content-ID: <1259.1472677104.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> I'll follow up with the fixes, both of which are rather
> straightforward.

Are they both in?

	[PATCH 2/2] rxrpc: fix undefined behavior in rxrpc_mark_call_released

David
