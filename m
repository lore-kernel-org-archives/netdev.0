From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Wed, 2 Sep 2015 10:00:25 +0800
Message-ID: <20150902020025.GA18184@gondor.apana.org.au>
References: <20150901114300.GB12691@gondor.apana.org.au>
 <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
 <20150901134310.GB27550@orbit.nwl.cc>
 <20150901135019.GA13629@gondor.apana.org.au>
 <20150901135618.GD27550@orbit.nwl.cc>
 <20150901140341.GA13757@gondor.apana.org.au>
 <20150901141305.GA11564@pox.localdomain>
 <20150901141639.GA13856@gondor.apana.org.au>
 <20150901145124.GC11564@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150901145124.GC11564@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 01, 2015 at 04:51:24PM +0200, Thomas Graf wrote:
>
> 1. The current in-kernel self-test
> 2. bind_netlink.c: https://github.com/tgraf/rhashtable

Thanks, I will try to reproduce this.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
