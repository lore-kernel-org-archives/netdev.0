From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Thu, 18 Jan 2007 22:27:44 -0500
Message-ID: <1169177264.2781.10.camel@localhost.localdomain>
References: <20070116185524.GA5681@dmt>
	 <1169020333.9175.15.camel@johannes.berg> <20070117184204.GA3899@dmt>
	 <20070117230654.GA9387@infradead.org>
	 <1169134905.2788.16.camel@localhost.localdomain>
	 <20070118224008.GA6675@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964810AbXASD0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 22:26:37 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20070118224008.GA6675@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-18 at 22:40 +0000, Christoph Hellwig wrote:
> On Thu, Jan 18, 2007 at 10:41:45AM -0500, Dan Williams wrote:
> > In the future we'll likely need some layering to support the 8385
> > SDIO/CF variant, but most likely not in way the USB support is currently
> > excessively layered and abstracted.
> 
> Yeah.  Let's summarize my unfortunately a bit too nasty comments and
> your more helpfull replies :-)
> 
> This driver still needs a lot more work, both to cleanup a lot of crap
> and integreate it better with the wireless stack.  And OLPC needs this
> is not going to be an excuse of it's own.

Of course; the we-need-it-now-so-you-take-it-now attitude never gets
vendors or anyone else anywhere, so there's no reason to expect it would
work for OLPC either.  OLPC does not need, nor does any of us who work
on it ask for, special treatment.  Stuff will go through the correct
channels and will follow the normal kernel process.  That's all we can
expect, and that's all we ask.

Cheers,
Dan


