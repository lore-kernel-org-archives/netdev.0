From: Marcelo Tosatti <marcelo@kvack.org>
Subject: [PATCH] Marvell Libertas 8388 802.11b/g USB driver
Date: Fri, 15 Dec 2006 20:51:23 -0200
Message-ID: <20061215225123.GA3231@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"John W. Linville" <linville@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:43592 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030350AbWLOXAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 18:00:20 -0500
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 

Marvell released a GPL driver for their 8388 wireless chip for USB
interface back in April.

The 8388 is the device being used by the OLPC laptop.

We have been working on cleaning it up for mainline inclusion. I think
the moment for wider review has arrived.

Since the diff is pretty large (700K) I've put it on the web at:
http://dev.laptop.org/~marcelo/libertas-8388-15122006.patch

And its GIT tree resides at:
http://git.infradead.org/?p=libertas-2.6.git;a=log

Comments are welcome

