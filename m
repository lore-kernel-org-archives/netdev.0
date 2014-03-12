From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 8/9] lg-vl600: Convert uses of
 __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 15:29:10 -0400 (EDT)
Message-ID: <20140312.152910.2161353215312957612.davem@davemloft.net>
References: <cover.1394644825.git.joe@perches.com>
	<90c51467c9cc8ca3b8e4d74a63da42b28d8d51ec.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <90c51467c9cc8ca3b8e4d74a63da42b28d8d51ec.1394644825.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:22:37 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
