From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] openvswitch: Use eth_mac_addr() instead of
 duplicating it
Date: Mon, 3 Dec 2012 22:47:21 +0000
Message-ID: <20121203224721.GC14494@casper.infradead.org>
References: <20121203221732.GA14494@casper.infradead.org>
 <CAEP_g=8+V=LN--ZkAgRHysUWwNJH1O=YDevbLH846nGZQkUpUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, dev@openvswitch.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59873 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab2LCWrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 17:47:24 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=8+V=LN--ZkAgRHysUWwNJH1O=YDevbLH846nGZQkUpUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/12 at 02:36pm, Jesse Gross wrote:
> On Mon, Dec 3, 2012 at 2:17 PM, Thomas Graf <tgraf@suug.ch> wrote:
> >
> > bonus: if we ever are to use IFF_LIVE_ADDR_CHANGE for
> > anything further than to check availability in eth_mac_addr(),
> > Open vSwitch will be ready for that.
> >
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> There's no need to send this patch twice (especially to a different
> set of people).  I'm currently reviewing a large patchset that was
> submitted before yours.

It's a trivial patch, you seemed busy and we might as well make use
of the open net-next window. I see nothing wrong with that.
