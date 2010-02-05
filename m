From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Thu, 04 Feb 2010 17:04:48 -0800 (PST)
Message-ID: <20100204.170448.149507765.davem@davemloft.net>
References: <1265324464.23523.51.camel@hawkeye.sandia.gov>
	<20100204.151357.18104114.davem@davemloft.net>
	<1265330214.23523.78.camel@hawkeye.sandia.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ktpedre@sandia.gov
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265330214.23523.78.camel@hawkeye.sandia.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kevin Pedretti" <ktpedre@sandia.gov>
Date: Thu, 4 Feb 2010 17:36:54 -0700

> Sure, I'm open to doing this and would appreciate any example drivers
> you could point me at.

I can't think of any sorry.

> We do need to keep the capability though of talking to Cray's
> existing proprietary "ethernet" over seastar driver, which the
> existing driver does.  If we go this route of being a non-Ethernet
> device, do you think it would still be possible to support this?

I don't think it will break communication with Cray's stuff.
