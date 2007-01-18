From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Thu, 18 Jan 2007 22:40:08 +0000
Message-ID: <20070118224008.GA6675@infradead.org>
References: <20070116185524.GA5681@dmt> <1169020333.9175.15.camel@johannes.berg> <20070117184204.GA3899@dmt> <20070117230654.GA9387@infradead.org> <1169134905.2788.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Marcelo Tosatti <marcelo@kvack.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:49542 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932684AbXARWkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 17:40:14 -0500
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1169134905.2788.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 18, 2007 at 10:41:45AM -0500, Dan Williams wrote:
> In the future we'll likely need some layering to support the 8385
> SDIO/CF variant, but most likely not in way the USB support is currently
> excessively layered and abstracted.

Yeah.  Let's summarize my unfortunately a bit too nasty comments and
your more helpfull replies :-)

This driver still needs a lot more work, both to cleanup a lot of crap
and integreate it better with the wireless stack.  And OLPC needs this
is not going to be an excuse of it's own.
