From: David Miller <davem@davemloft.net>
Subject: Re: tun: Return -EINVAL if neither IFF_TUN nor IFF_TAP is set.
Date: Tue, 22 Sep 2009 14:26:14 -0700 (PDT)
Message-ID: <20090922.142614.257492594.davem@davemloft.net>
References: <20090917073614.15217260031@msa105lp.auone-net.jp>
	<200909180754.05817.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: slash@ma.neweb.ne.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paul.moore@hp.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753426AbZIVVZ5@vger.kernel.org>
In-Reply-To: <200909180754.05817.paul.moore@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 18 Sep 2009 07:54:05 -0400

> On Thursday 17 September 2009 03:36:13 am Kusanagi Kouichi wrote:
>> After commit 2b980dbd77d229eb60588802162c9659726b11f4
>> ("lsm: Add hooks to the TUN driver") tun_set_iff doesn't
>> return -EINVAL though neither IFF_TUN nor IFF_TAP is set.
>> 
>> Signed-off-by: Kusanagi Kouichi <slash@ma.neweb.ne.jp>
> 
> Sorry about that, my mistake, thanks for finding and fixing this.
> 
> Reviewed-by: Paul Moore <paul.moore@hp.com>

Applied.
