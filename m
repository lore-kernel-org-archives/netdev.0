From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v13 10/16] Add a hook to intercept external buffers
 from NIC driver.
Date: Fri, 29 Oct 2010 13:28:36 -0700 (PDT)
Message-ID: <20101029.132836.115944599.davem@davemloft.net>
References: <33f51c5eddec843260451eccbfa3c5fdea13b479.1287132437.git.xiaohui.xin@intel.com>
	<20101019.082401.28817543.davem@davemloft.net>
	<F2E9EB7348B8264F86B6AB8151CE2D7931E3CB834A@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D7931E3CB834A@shsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Date: Wed, 27 Oct 2010 09:33:12 +0800

> Somehow, it seems not a trivial work to support it now. Can we support it
> later and as a todo with our current work?

I would prefer the feature work properly, rather than only in specific
cases, before being integated.
