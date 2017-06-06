From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] rxrpc: Support service upgrade
Date: Tue, 06 Jun 2017 12:06:31 -0400 (EDT)
Message-ID: <20170606.120631.319115379546594307.davem@davemloft.net>
References: <149674286135.26138.12623162384868251541.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149674286135.26138.12623162384868251541.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 06 Jun 2017 10:54:21 +0100

> Here's a set of patches that allow AF_RXRPC to support the AuriStor service
> upgrade facility.  This allows the server to change the service ID
> requested to an upgraded service if the client requests it upon the
> initiation of a connection.
 ...
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20170606

Pulled, thanks David.
