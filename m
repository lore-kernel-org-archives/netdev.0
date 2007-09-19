From: "Alexander Indenbaum" <baum@tehutinetworks.net>
Subject: RE: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Wed, 19 Sep 2007 21:28:32 +0200
Message-ID: <20070919192818.D5500C01972@relay.tehutinetworks.net>
References: <20070919174103.GB22795@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jeff@garzik.org>, <davem@davemloft.org>,
	<akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	"'Nadav Shemer'" <nadav@tehutinetworks.net>,
	"'Andy Gospodarek'" <andy@greyhouse.net>
To: "'Christoph Hellwig'" <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bzq-219-225-50.pop.bezeqint.net ([62.219.225.50]:42322 "EHLO
	relay.tehutinetworks.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbXIST2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 15:28:51 -0400
In-Reply-To: <20070919174103.GB22795@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> Ok, so you do irq acquire/release in open/close so that bit is fine.
> The code might actually work as is, sorry for the noise.

It is no noise at all. Thank you for your feedback.


