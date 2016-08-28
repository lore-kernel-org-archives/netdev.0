From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/5] rxrpc: fix last_call processing
Date: Sun, 28 Aug 2016 09:42:17 +0100
Message-ID: <13158.1472373737@warthog.procyon.org.uk>
References: <20160826152546.604384-4-arnd@arndb.de> <20160826152546.604384-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160826152546.604384-4-arnd@arndb.de>
Content-ID: <13157.1472373737.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is fixed by:

	commit 2266ffdef5737fdfa96005204fc5606dbd559956
	subject: rxrpc: Fix conn-based retransmit

which is in net-next.

David
