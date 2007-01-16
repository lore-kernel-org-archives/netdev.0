From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 16 Jan 2007 17:41:40 -0500
Message-ID: <1168987300.7981.3.camel@localhost.localdomain>
References: <20070116185524.GA5681@dmt>  <200701162032.54118.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbXAPWj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 17:39:26 -0500
To: Arkadiusz Miskiewicz <arekm@maven.pl>
In-Reply-To: <200701162032.54118.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-16 at 20:32 +0100, Arkadiusz Miskiewicz wrote:
> On Tuesday 16 January 2007 19:55, you wrote:
> > Announcing an updated patch of the Marvell Libertas 8388 802.11 USB
> > driver.
> >
> > Diff can be found at
> > http://dev.laptop.org/~marcelo/libertas-8388-16012007.patch
> 
> Is core chip somehow close to pci/pci-e:
> 
> 00:07.0 Ethernet controller: Marvell Technology Group Ltd. 88W8310 and 
> 88W8000G [Libertas] 802.11g client chipset (rev 07)

Not that close as far as we know; the 8388 and the 8338 are different
product groups within Marvell and different chips.  But we can probably
find out.  They seem to like naming different hardware with similar
product numbers.

dan

