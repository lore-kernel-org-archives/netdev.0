From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netpoll: Remove unused EXPORT_SYMBOLs of
 netpoll_poll and netpoll_poll_dev
Date: Sun, 03 Jul 2011 20:02:24 -0700 (PDT)
Message-ID: <20110703.200224.1596548736594048749.davem@davemloft.net>
References: <cover.1309482314.git.joe@perches.com>
	<282ce7d68b97c4dbfb759c1c0752e6cbddfeeafc.1309482314.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, amwang@redhat.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <282ce7d68b97c4dbfb759c1c0752e6cbddfeeafc.1309482314.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 30 Jun 2011 18:08:57 -0700

> Unused symbols waste space.
> 
> Commit 0e34e93177fb
> "(netpoll: add generic support for bridge and bonding devices)"
> added the symbol more than a year ago with the promise of "future use".
> 
> Because it is so far unused, remove it for now.
> It can be easily readded if or when it actually needs to be used.
> 
> cc: WANG Cong <amwang@redhat.com>
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
