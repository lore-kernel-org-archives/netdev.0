From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 4274] New: ipv6: Unknown symbol
 tcp_timer_bug_msg
Date: Wed, 2 Mar 2005 12:16:33 -0800
Message-ID: <20050302121633.2b28c058.davem@davemloft.net>
References: <20050302091907.19bb2b2e.akpm@osdl.org>
	<20050303.023706.64945563.yoshfuji@wide.ad.jp>
	<20050302195110.GA27736@excelhustler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@wide.ad.jp, akpm@osdl.org, netdev@oss.sgi.com
To: John Goerzen <jgoerzen@complete.org>
In-Reply-To: <20050302195110.GA27736@excelhustler.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2005 13:51:10 -0600
John Goerzen <jgoerzen@complete.org> wrote:

> On Thu, Mar 03, 2005 at 02:37:06AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > In article <20050302091907.19bb2b2e.akpm@osdl.org> (at Wed, 2 Mar 2005 09:19:07 -0800), Andrew Morton <akpm@osdl.org> says:
> > 
> > > modprobe ipv6 fails with:
> > > 
> > > ipv6: Unknown symbol tcp_timer_bug_msg
> > 
> > Please try this.
> 
> That fixed it.  Thanks!

I'll apply this patch later today, thanks everyone.
