From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: the next chunk of iov_iter-net stuff for review
Date: Tue, 9 Dec 2014 23:13:10 +0000
Message-ID: <20141209231310.GM22149@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 09, 2014 at 10:49:28PM +0000, Al Viro wrote:

> OK, rebase is in
> git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem-2,
> individual patches - in followups (first 13 - iov_iter, then 12 net-related)

PS: the pile next after that one is also there, in 
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git iov_iter-net-2
but that one contains several things I'd *really* like to hear comments
about (asked about all of them on netdev, no reply so far).  Let's sort this
one out first...

Al, diving back into VFS-related queues...
