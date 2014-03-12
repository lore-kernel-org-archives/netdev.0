From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/9] ixgbevf: Convert uses of __constant_<foo>
 to <foo>
Date: Wed, 12 Mar 2014 15:29:43 -0400 (EDT)
Message-ID: <20140312.152943.1215580027221343113.davem@davemloft.net>
References: <cover.1394644825.git.joe@perches.com>
	<6477c916f14711f9f0cd02610a8b8a3c1804a83e.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6477c916f14711f9f0cd02610a8b8a3c1804a83e.1394644825.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:22:35 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Will let the Intel folks pick this up.
