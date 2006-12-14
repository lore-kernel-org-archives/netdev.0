From: Jim Lewis <jim@jklewis.com>
Subject: Re: [PATCH 2/14] Spidernet add net_ratelimit to suppress long
	output
Date: Thu, 14 Dec 2006 00:13:19 -0600
Message-ID: <1166076799.21877.15.camel@localhost.localdomain>
References: <20061213210010.GR4329@austin.ibm.com>
	 <20061213210825.GB1915@austin.ibm.com>
	 <1166052679.6838.1.camel@concordia.ozlabs.ibm.com>
Reply-To: jim@jklewis.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>,
	Andrew Morton <akpm@osdl.org>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	linuxppc-dev@ozlabs.org, Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from omta01-pub.suddenlink.net ([208.180.40.73]:59751 "EHLO
	omta01.suddenlink.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbWLNGq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 01:46:27 -0500
To: michael@ellerman.id.au
In-Reply-To: <1166052679.6838.1.camel@concordia.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 It is in the LTC Bugzilla. I just checked and it is still there :)

Jim


On Thu, 2006-12-14 at 10:31 +1100, Michael Ellerman wrote:
> On Wed, 2006-12-13 at 15:08 -0600, Linas Vepstas wrote:
> > This patch adds net_ratelimit to many of the printks in order to
> > limit extraneous warning messages (created in response to Bug 28554).
> 
> Bug 28554 in which bug tracking system? I can't find it in LTC or
> kernel.org bugzilla.
> 
> cheers
> 

