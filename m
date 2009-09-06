From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 06 Sep 2009 14:14:19 -0700 (PDT)
Message-ID: <20090906.141419.212222652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758768AbZIFVOH@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull to get this build regression fix.

Thanks!

The following changes since commit e07cccf4046978df10f2e13fe2b99b2f9b3a65db:
  Linus Torvalds (1):
        Linux 2.6.31-rc9

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      gianfar: Fix build.

 drivers/net/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
