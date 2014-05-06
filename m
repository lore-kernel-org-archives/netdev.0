From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 13:44:17 -0700
Message-ID: <20140506204417.GQ19657@tassilo.jf.intel.com>
References: <20140506164546.GB20536@cloud>
 <20140506.131752.740569380523989782.davem@davemloft.net>
 <20140506172106.GB20776@cloud>
 <20140506.132501.331724703594119414.davem@davemloft.net>
 <20140506201145.GC21332@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com
To: josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140506201145.GC21332@cloud>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> And if you're asking for someone to help pay attention to bug reports so
> you don't have to, that's reasonable as well; just like you probably
> have a stock response for "that's a crazy distro kernel, ask them about
> it and not me", you could have a stock response for "that kernel has the
> crazy embedded option turned on, ask the embedded people about it and
> not me".  It doesn't just have to be *your* problem alone.

We could add a tainted flag for these configurations and a message at bootup
to make it obvious in bug reports.  Would that help?

-Andi
