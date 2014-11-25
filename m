From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 01/17] new helper: skb_copy_and_csum_datagram_msg()
Date: Tue, 25 Nov 2014 20:59:11 +0000
Message-ID: <20141125205911.GA29748@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
 <1416924151-28698-1-git-send-email-viro@ZenIV.linux.org.uk>
 <20141125.142820.78809050565547546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141125.142820.78809050565547546.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 02:28:20PM -0500, David Miller wrote:
> 
> Al, this series looks fine to me, do you have a tree I can pull
> it from?

Er...  Same as the last time?

git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem

and there's more fun stuff in #iov_iter-net in the same tree, but that's
the next batch...
