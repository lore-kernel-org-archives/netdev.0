From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [Kernel-janitors] net/atm/clip.c: check kmem_cache_create()
 #1
Date: Wed, 4 Feb 2004 23:24:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040204232414.05dc8702.davem@redhat.com>
References: <20040128091803.1da4cf1c.rddunlap@osdl.org>
	<200402041904.i14J4GRr017777@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams (contractor) <chas@cmf.nrl.navy.mil>
In-Reply-To: <200402041904.i14J4GRr017777@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 04 Feb 2004 14:04:17 -0500
chas williams (contractor) <chas@cmf.nrl.navy.mil> wrote:

> randy, i think it should probably return -ENOMEM instead of -1.
> 
> dave, please apply the following to both the 2.6 and 2.4 trees.

Applied, thanks guys.
