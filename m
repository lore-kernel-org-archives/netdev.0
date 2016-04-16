From: David Miller <davem@davemloft.net>
Subject: Re: [net][PATCH v2 0/2] RDS: couple of fixes for 4.6
Date: Sat, 16 Apr 2016 18:53:42 -0400 (EDT)
Message-ID: <20160416.185342.1833113899705435419.davem@davemloft.net>
References: <1460655807-26236-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460655807-26236-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Thu, 14 Apr 2016 10:43:25 -0700

>   git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git for_4.6/net/rds-fixes

I have no idea how you set this up, but there is no WAY this can be
pulled from by me.

When I try to pull it into 'net' I get 2690 objects.  That means you
didn't base it upon the 'net' tree which you must do.  You can't base
it upon Linus's tree, because if you do I'll get a ton of changes that
are absolutely not appropriate to be pulled into my 'net' tree.

Are you always doing this?  Working against Linus's tree instead of
mine?
