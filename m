From: David Miller <davem@davemloft.net>
Subject: merge window now closed
Date: Wed, 24 Jun 2009 17:32:54 -0700 (PDT)
Message-ID: <20090624.173254.153450975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, linux-ide@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-ide-owner@vger.kernel.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Now that the 2.6.31 merge window is closed, you should be fixing
regressions and testing things.

Things will tighten, as usual.

As soon as Stephen Rothwell gives the OK, I'll open up new -next trees
for networking/sparc/IDE.  In the mean time non-fixes (and after RC2
or so, non-regression-fixes) will accumulate in patchwork until the
-next tree(s) are cut.

Please respect these rules so 2.6.31 can go out quickly and we can
then merge all kinds of new fun stuff for 2.6.32.

Thanks everyone for all of your hard work this merge window!
