From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] AF_RXRPC fixes and development [ver #2]
Date: Thu, 06 Mar 2014 17:38:45 -0500 (EST)
Message-ID: <20140306.173845.733270648823204984.davem@davemloft.net>
References: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
	<8007.1394144113@warthog.procyon.org.uk>
	<8493.1394145149@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8493.1394145149@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 06 Mar 2014 22:32:29 +0000

> David Miller <davem@davemloft.net> wrote:
> 
>> If you do, submit just the bug fixes against 'net'
> 
> One more question:  When you say "against 'net'", do you mean a particular
> branch of a git tree?  If so, disregard the pull request I just sent you and
> I'll rebase.

I do not use branches.

I instead have just two trees, 'net' and 'net-next'
