From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: netif_rx packet dumping
Date: Wed, 9 Mar 2005 16:03:30 -0800
Message-ID: <20050309160330.2f9688e1@dxpl.pdx.osdl.net>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<42278122.6000000@ev-en.org>
	<20050303133659.0d224e61.davem@davemloft.net>
	<42278554.2090902@ev-en.org>
	<20050303135718.2e1a0170.davem@davemloft.net>
	<422DC7CE.2040800@ev-en.org>
	<m1y8cykr7i.fsf@muc.de>
	<20050308100902.24b67b2f.davem@davemloft.net>
	<422DEE85.5010302@candelatech.com>
	<20050309235728.GV31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
        "David S. Miller"
 <davem@davemloft.net>, Andi Kleen <ak@muc.de>,
        baruch@ev-en.org, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050309235728.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 00:57:28 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> > Of course...this might be things for 2.7 since lots of modules will probably
> > be accessing these fields.  Maybe to get started we could add macros to grab
> > the flags and such so that when we finally do collapse things into a single
> > flags field the external code doesn't have to know or care?

Their may never be a 2.7, don't wait that long.
