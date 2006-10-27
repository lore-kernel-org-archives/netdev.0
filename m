From: netdev@sc-software.com
Subject: ethernet mac filter configuration
Date: Thu, 26 Oct 2006 17:32:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.63.0610261722220.14561@sc-software.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: John Heil <netdev@sc-software.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scsoftware.csnc.net ([205.214.229.65]:32953 "EHLO
	sc-software.com") by vger.kernel.org with ESMTP id S1946059AbWJ0A1x
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:27:53 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Probably dumb Q/wrong place, but...

What, if any, user space command is available/recommended
for adding/deleting MAC addresses and masks to hardware
based ARC/CAM/MAC address filter memory on chip.

I've done a driver for a new 10/100 MAC/PHY combo (currently
running on ARM) that has on chip memory and logic for
this kind of filtration.

I'm aware of the kernel multicast support and I've tied
my set_multicast_list() function to needed chip interface
but can't find a standard user space command to instantiate
the list with MAC addresses/masks.


Thnx v much,
johnh


.
===========================================================
John Heil
South Coast Software
Custom firmware, device drivers and board bring up services
Ph: 1-714-774-6952
Fx: 1-714-774-7053
www.sc-software.com
email: johnhscs@sc-software.com
===========================================================

