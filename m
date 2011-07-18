From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tulip: dmfe: Remove old log spamming pr_debugs
Date: Mon, 18 Jul 2011 11:05:32 -0700
Message-ID: <1311012332.2286.110.camel@Joe-Laptop>
References: <201107181440.35886.jdelvare@suse.de>
	 <0a5f6c4c4c948dd5ff827bb5c5517294c9410bfc.1311000440.git.joe@perches.com>
	 <20110718.104537.546991191560526229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, grundler@parisc-linux.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110718.104537.546991191560526229.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-07-18 at 10:45 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 18 Jul 2011 07:50:33 -0700
> > Commit 726b65ad444d ("tulip: Convert uses of KERN_DEBUG") enabled
> > some old previously inactive uses of pr_debug converted by
> > commit dde7c8ef1679 ("tulip/dmfe.c: Use dev_<level> and pr_<level>").
> > Remove these pr_debugs.
> > Signed-off-by: Joe Perches <joe@perches.com>
> Applied.

I believe this should go into current if you push
one more to Linus or maybe stable for 3.0.

cheers, Joe
