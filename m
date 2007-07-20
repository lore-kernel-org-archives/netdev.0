From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ANNOUNCE: igb: Intel 82575 Gigabit Ethernet driver (PCI-Express)
Date: Fri, 20 Jul 2007 08:33:47 +0100
Message-ID: <20070720073347.GA29575@infradead.org>
References: <46980ADA.5050104@intel.com> <469ED3D7.6040905@garzik.org> <469FF922.2090900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42821 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759785AbXGTHeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 03:34:12 -0400
Content-Disposition: inline
In-Reply-To: <469FF922.2090900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 04:52:02PM -0700, Kok, Auke wrote:
> Why don't you accept it now and allow us the time to work on this in the 
> coming period? The driver works, performs better than all 8257x hardware 
> and uses less CPU utilization. That must be good for everyone. Keeping it 
> outside of the linux tree is just going to postpone testing the 
> non-internal API parts.

Well, these useless abstractions are really annoying and nothing we allow
into other drivers either.  So I'd be miuch happier if you stripped them
out quickly.  It's not like it's a whole lot of work.

