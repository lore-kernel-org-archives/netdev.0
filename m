From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] afs: Use system UUID generation
Date: Mon, 13 Feb 2017 22:09:54 -0500 (EST)
Message-ID: <20170213.220954.1817553128967975340.davem@davemloft.net>
References: <148674517199.6350.17724845267620917182.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148674517199.6350.17724845267620917182.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 10 Feb 2017 16:46:12 +0000

> There is now a general function for generating a UUID and AFS should make
> use of it.  It's also been recommended to me that I switch to using random
> rather than time plus MAC address-based UUIDs which this function does.
> 
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20170210

Pulled, thanks David.
