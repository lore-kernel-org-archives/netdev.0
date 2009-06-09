From: David Miller <davem@davemloft.net>
Subject: Re: [PULL REQUEST] IEEE 802.15.4 stack: generic parts v4
Date: Tue, 09 Jun 2009 05:07:06 -0700 (PDT)
Message-ID: <20090609.050706.241520518.davem@davemloft.net>
References: <cover.1244498867.git.slapin@ossfans.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, dbaryshkov@gmail.com, sfr@canb.auug.org.au
To: slapin@ossfans.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932131AbZFIMHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:07:04 -0400
In-Reply-To: <cover.1244498867.git.slapin@ossfans.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Lapin <slapin@ossfans.org>
Date: Tue,  9 Jun 2009 02:18:46 +0400

> Major changes from previous post:
>  * Changed net/ieee802154/Makefile according to Sam Ravnborg suggestion
> 
> The following changes since commit 81ee1bad86bd6752c626018d43a74e3f81f1ae72:
>   Linus Torvalds (1):
>         Merge branch 'for-linus' of git://git.kernel.org/.../viro/vfs-2.6
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/slapin/lowpan.git for-next

I can't pull from a tree that is prepared like this.

You have to make a clean clone of the net-next-2.6 GIT tree and
add your changes on top of that.  When you use a clone of
Linus's tree, I'm going to end up getting all kinds of changes
from upstream that I haven't merged into net-next-2.6 yet which
creates a complete mess.

I'm going to apply these changes by hand.
