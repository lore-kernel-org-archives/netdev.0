From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.0-test4][NET] sk_mca.c: fix linker error
Date: Sun, 24 Aug 2003 04:41:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030824044150.6b396fdc.davem@redhat.com>
References: <1061644938.2787.22.camel@lima.royalchallenge.com>
	<1061646315.1141.26.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vinay-rc@naturesoft.net, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay-rc@naturesoft.net>
In-Reply-To: <1061646315.1141.26.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 23 Aug 2003 19:15:15 +0530
Vinay K Nallamothu <vinay-rc@naturesoft.net> wrote:

> On Sat, 2003-08-23 at 18:52, Vinay K Nallamothu wrote:
> > Hi,
> > 
> > This patch fixes the following linker error due to a typo:
> > 
> > *** Warning: "spin_lock_irqrestore" [drivers/net/sk_mca.ko] undefined!
> Oops. missed out few more. Here is the updated patch.

Aplied, thanks.
