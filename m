From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 00/13] RxRPC: Rewrite part 1
Date: Fri, 04 Mar 2016 22:33:38 +0000
Message-ID: <6513.1457130818@warthog.procyon.org.uk>
References: <20160304.172010.571829527806753588.davem@davemloft.net> <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304.172010.571829527806753588.davem@davemloft.net>
Content-ID: <6512.1457130818.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> Can you go through and use "unsigned int" instead of just plain
> "unsigned" in the RxRPC code?

Do you mind if I leave it to after the rewrite?  I don't particularly want to
have to rejig all the patches I have.

David
