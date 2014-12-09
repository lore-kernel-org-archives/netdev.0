From: David Miller <davem@davemloft.net>
Subject: Re: the next chunk of iov_iter-net stuff for review
Date: Tue, 09 Dec 2014 15:07:32 -0500 (EST)
Message-ID: <20141209.150732.158834258918114526.davem@davemloft.net>
References: <20141125205911.GA29748@ZenIV.linux.org.uk>
	<20141126.122727.1791815907895724977.davem@davemloft.net>
	<20141205055623.GQ29748@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 5 Dec 2014 05:56:23 +0000

> 	OK, here's the tentative next batch (covers most of the ->recvmsg()
> side of conversion).  That's on top of merge of net-next#master with
> vfs#iov_iter (the latter had been posted earlier today, Cc'd to netdev among
> other places).  This series corresponds to vfs#for-davem.  Review and comments
> would be very welcome...

Al, what's the state of this?  The iov_iter rewrite had some changes
recently.

Also, never assume I just know what GIT url to pull from, always
explicitly state where you want me to pull changes from.

Thanks.
