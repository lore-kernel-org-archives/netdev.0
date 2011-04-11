From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: 2.6.39-rc2 boot crash
Date: Tue, 12 Apr 2011 02:06:57 +0400
Message-ID: <20110411220657.GB5783@ioremap.net>
References: <20110406184753.GA7691@mgebm.net>
 <1302115953.8094.217.camel@nimitz>
 <20110406212041.GA2596@mgebm.net>
 <20110406.142157.68145422.davem@davemloft.net>
 <20110406220512.GA2460@mgebm.net>
 <4D9D9AA4.6060304@trash.net>
 <20110411210746.GA2453@mgebm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, dave@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org, gregkh@suse.de,
	ksrinivasan@novell.com, NetDev <netdev@vger.kernel.org>
To: Eric B Munson <emunson@mgebm.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110411210746.GA2453@mgebm.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Mon, Apr 11, 2011 at 05:07:47PM -0400, Eric B Munson (emunson@mgebm.net) wrote:
> > I can't figure this out, the only thing that should have changed is the
> > time the initial PROC_CN_MCAST_LISTEN message is received. Apparently
> > at that point connector is not fully initialized yet. Please post your
> > config and the full boot log. Thanks.
> > 
> 
> I am still seeing this on Linus' tree, is there anything more I can do to help
> track the problem?

Patrick, do you need my assist on this bug?

-- 
	Evgeniy Polyakov
