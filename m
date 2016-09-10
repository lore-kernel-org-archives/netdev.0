From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] rxrpc: Rewrite data and ack handling
Date: Fri, 09 Sep 2016 19:25:19 -0700 (PDT)
Message-ID: <20160909.192519.837318854325070157.davem@davemloft.net>
References: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 08 Sep 2016 12:43:28 +0100

> This patch set constitutes the main portion of the AF_RXRPC rewrite.  It
> consists of five fix/helper patches:
 ...
> And then there are two patches that form the main part:
 ...
> With this, the majority of the AF_RXRPC rewrite is complete.
 ...
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160908

Pulled, however I personally would have tried to split patch #7 up a bit, it
was really huge and hard to audit/review in any meaningful way.
