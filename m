From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] refactor code and mark expected switch
 fall-throughs
Date: Sun, 29 Oct 2017 10:45:41 +0900 (KST)
Message-ID: <20171029.104541.1487088453362795756.davem@davemloft.net>
References: <b0e6de21-b258-dc78-4710-a61b81ec419c@trinnet.net>
        <20171027144853.Horde.ExzHfROE4gaCiHalihXFClP@gator4166.hostgator.com>
        <e5c376f0-fdd0-78a7-a40f-0b990cff0023@trinnet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: garsilva@embeddedor.com, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, ralf@linux-mips.org, wharms@bfs.de,
        hal@kd.net.au, f6bvp@free.fr, thomas@osterried.de
To: linux-hams@trinnet.net
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <e5c376f0-fdd0-78a7-a40f-0b990cff0023@trinnet.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Ranch <linux-hams@trinnet.net>
Date: Sat, 28 Oct 2017 10:53:24 -0700

> Does anyone else have thoughts on this topic?

I think you are making a mountain out of a mole hill.

If you care so much about this, set things up so that entities such as
the kbuild test robot run whatever tests you think are necessary.

Otherwise, continually test the stack yourself and report any
regressions here as fast as you can.

If soemone can't be bothered to verify or test someone's change in 2
or 3 days, except in extreme circumstances, I absolutely refuse to
burdon the submitter and let their patches rot in the queue.

That's unacceptable.

That's the proper way to deal with this, without unreasonably
burdoning people who just want to keep the code across the tree modern
and more up to date.

Thank you.

