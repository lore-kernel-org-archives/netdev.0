From: Arjan van de Ven <arjan@infradead.org>
Subject: netdev data (was Re: Oops/Warning report for the week of December
 3rd, 2008)
Date: Wed, 3 Dec 2008 19:02:05 -0800
Message-ID: <20081203190205.65425f6e@infradead.org>
References: <20081203184652.0601b86b@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39898 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbYLDDAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 22:00:47 -0500
Received: from c-67-171-137-96.hsd1.or.comcast.net ([67.171.137.96] helo=localhost.localdomain)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1L84SL-0005xw-Gz
	for netdev@vger.kernel.org; Thu, 04 Dec 2008 03:00:46 +0000
In-Reply-To: <20081203184652.0601b86b@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Dec 2008 18:46:52 -0800
Arjan van de Ven <arjan@linux.intel.com> wrote:

> This week, a total of 11349 oopses and warnings have been reported,
> compared to 4327 reports in the previous week.
> 
> 

for netdev only: the stats of device timeouts

last 7 days:  
 count |          guilty           
-------+---------------------------
   432 | dev_watchdog(r8169)
   292 | dev_watchdog(sis900)
    84 | dev_watchdog(atl1)
    60 | dev_watchdog(ne2k-pci)
    53 | dev_watchdog(gl620a)
    51 | dev_watchdog(via-rhine)
    48 | dev_watchdog(cdc_ether)
    45 | dev_watchdog(8139too)
    31 | dev_watchdog(atl2)
    27 | dev_watchdog(orinoco_pci)
    21 | dev_watchdog(orinoco_cs)
    15 | dev_watchdog(forcedeth)
    15 | dev_watchdog(fealnx)



all time:

count |           guilty           
-------+----------------------------
  1801 | dev_watchdog(sis900)
  1795 | dev_watchdog(r8169)
   320 | dev_watchdog(via-rhine)
   297 | dev_watchdog(cdc_ether)
   220 | dev_watchdog(8139too)
   213 | dev_watchdog(usbnet)
   185 | dev_watchdog(atl1)
   177 | dev_watchdog(ne2k-pci)
   169 | dev_watchdog(via_rhine)
   166 | dev_watchdog(8390)
   125 | dev_watchdog(atl2)
   125 | dev_watchdog(gl620a)
   107 | dev_watchdog(forcedeth)
   102 | dev_watchdog(fealnx)


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
