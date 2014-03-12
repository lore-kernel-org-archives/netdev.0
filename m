From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 7/9] xilinx: Convert uses of __constant_<foo>
 to <foo>
Date: Wed, 12 Mar 2014 15:29:31 -0400 (EDT)
Message-ID: <20140312.152931.1828799203352054913.davem@davemloft.net>
References: <cover.1394644825.git.joe@perches.com>
	<2722ce785ea17ccd8bdbb20f0accd89232aa2b2a.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michal.simek@xilinx.com,
	anirudh@xilinx.com, John.Linn@xilinx.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2722ce785ea17ccd8bdbb20f0accd89232aa2b2a.1394644825.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:22:36 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
