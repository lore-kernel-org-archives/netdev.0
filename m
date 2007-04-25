From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] AF_RXRPC socket family and AFS rewrite [try #3]
Date: Wed, 25 Apr 2007 12:43:54 -0700 (PDT)
Message-ID: <20070425.124354.55506567.davem@davemloft.net>
References: <20070425041514.bb770377.akpm@linux-foundation.org>
	<20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
	<13484.1177508312@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <13484.1177508312@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Wed, 25 Apr 2007 14:38:32 +0100

> I think the idea is for them (or at least some of them) to go
> through one of DaveM's net git trees anyway.

Then please generate your patches against my net-2.6.21 GIT
tree.  Most of your initial patches in the series (the SKB
routine one for example) are already in my tree.
