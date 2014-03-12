From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] tipc: Convert uses of __constant_<foo> to
 <foo>
Date: Wed, 12 Mar 2014 15:29:00 -0400 (EDT)
Message-ID: <20140312.152900.1060649380295869052.davem@davemloft.net>
References: <cover.1394643455.git.joe@perches.com>
	<3f2447bc68b2fce7aa854eca0f6a1e263ec3669a.1394643455.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3f2447bc68b2fce7aa854eca0f6a1e263ec3669a.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:04:20 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
