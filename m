From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 5/6] netfilter: Convert uses of __constant_<foo>
 to <foo>
Date: Thu, 13 Mar 2014 14:13:56 +0100
Message-ID: <20140313131356.GA5954@localhost>
References: <cover.1394643455.git.joe@perches.com>
 <d0259d9122d308e3297cac6f7bc47c9955c3597b.1394643455.git.joe@perches.com>
 <20140312.152855.298436374579216260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, netdev@vger.kernel.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140312.152855.298436374579216260.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 03:28:55PM -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 12 Mar 2014 10:04:19 -0700
> 
> > The use of __constant_<foo> has been unnecessary for quite awhile now.
> > 
> > Make these uses consistent with the rest of the kernel.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Will let the netfilter folks pick this up.

Applied, thanks!
