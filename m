From: David Miller <davem@davemloft.net>
Subject: Re: [Bug, PATCH and another Bug] Was: Fix refcounting problem with
 netif_rx_reschedule()
Date: Wed, 19 Sep 2007 22:12:24 -0700 (PDT)
Message-ID: <20070919.221224.26966518.davem@davemloft.net>
References: <200709191523.48874.ossthema@de.ibm.com>
	<OF42EA8B8A.CAFE186B-ON6525735C.001BE132-6525735C.001C6EC0@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, raisch@de.ibm.com, rdreier@cisco.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45723
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752714AbXITFMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 01:12:24 -0400
In-Reply-To: <OF42EA8B8A.CAFE186B-ON6525735C.001BE132-6525735C.001C6EC0@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 20 Sep 2007 10:40:33 +0530

> I like the clean changes made by Dave to fix this, and will test it
> today (if I can get my crashed system to come up).

I would very much appreciate this testing, as I'm rather sure we've
plugged up the most serious holes at this point.
