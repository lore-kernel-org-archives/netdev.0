From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] netfilter: Convert uses of
 __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 15:28:55 -0400 (EDT)
Message-ID: <20140312.152855.298436374579216260.davem@davemloft.net>
References: <cover.1394643455.git.joe@perches.com>
	<d0259d9122d308e3297cac6f7bc47c9955c3597b.1394643455.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d0259d9122d308e3297cac6f7bc47c9955c3597b.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:04:19 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Will let the netfilter folks pick this up.
