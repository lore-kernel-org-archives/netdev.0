From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Thu, 04 Feb 2010 15:13:57 -0800 (PST)
Message-ID: <20100204.151357.18104114.davem@davemloft.net>
References: <1265160242.15726.20.camel@hawkeye.sandia.gov>
	<20100202.174045.135005544.davem@davemloft.net>
	<1265324464.23523.51.camel@hawkeye.sandia.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ktpedre@sandia.gov
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265324464.23523.51.camel@hawkeye.sandia.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kevin Pedretti" <ktpedre@sandia.gov>
Date: Thu, 4 Feb 2010 16:01:04 -0700

> Please let me know if these issues are show-stoppers as far as inclusion
> goes.  We would like to get this open-source driver into the kernel so
> us and others with Cray XT systems can start to benefit from it, and
> continue to automatically track kernel API changes. 

I may let it in as-is, thanks for the explanations.

Could you at least consider perhaps that since it isn't
really ethernet, not pretending that it is may be something
to look at?
