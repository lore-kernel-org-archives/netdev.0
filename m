From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: Signed-off-by missing for commit in the net-next tree
Date: Tue, 31 Oct 2017 16:40:19 +1100
Message-ID: <20171031164019.164de3db@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Francois Romieu <romieu@fr.zoreil.com>,
        Kirill Smelkov <kirr@nexedi.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Commit

  509708310cf9 ("r8169: Add support for interrupt coalesce tuning (ethtool -C)")

is missing a Signed-off-by from its author (or its author is wrong).

-- 
Cheers,
Stephen Rothwell
