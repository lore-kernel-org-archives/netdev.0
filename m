From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] net: Convert uses of __constant_<foo> to
 <foo>
Date: Wed, 12 Mar 2014 15:28:39 -0400 (EDT)
Message-ID: <20140312.152839.798485560031245185.davem@davemloft.net>
References: <cover.1394643455.git.joe@perches.com>
	<5bc6ebcb56edc59ea478416474fbbe52200a8cb2.1394643455.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5bc6ebcb56edc59ea478416474fbbe52200a8cb2.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:04:17 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
