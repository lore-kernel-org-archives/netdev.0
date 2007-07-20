From: Stefan Rompf <stefan@loplof.de>
Subject: Re: ANNOUNCE: igb: Intel 82575 Gigabit Ethernet driver (PCI-Express)
Date: Fri, 20 Jul 2007 10:23:21 +0200
Message-ID: <200707201023.21786.stefan@loplof.de>
References: <46980ADA.5050104@intel.com> <469FF922.2090900@intel.com> <20070720073347.GA29575@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p07-fb.rzone.de ([81.169.146.215]:58923 "EHLO
	cg-p07-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765694AbXGTIVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 04:21:14 -0400
Received: from mo-p07-ob.rzone.de (mrclete-mo-p07-ob.mail [192.168.63.176])
	by charnel-fb-04.store (RZmta 8.2) with ESMTP id R040bej6K8KvOp
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 10:21:12 +0200 (MEST)
In-Reply-To: <20070720073347.GA29575@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 20. Juli 2007 09:33 schrieben Sie:

> Well, these useless abstractions are really annoying and nothing we allow
> into other drivers either.

However, they make it easier for multiple developers to work as a team. This 
is useful for development pace and makes maintainance less dependant on one 
person.

Stefan
