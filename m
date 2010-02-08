From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 15239] New: Problem with network performance
 after a while.
Date: Mon, 08 Feb 2010 15:14:22 -0800 (PST)
Message-ID: <20100208.151422.144771179.davem@davemloft.net>
References: <bug-15239-10286@http.bugzilla.kernel.org/>
	<20100208141513.b5d0be56.akpm@linux-foundation.org>
	<alpine.WNT.2.00.1002081432390.6892@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jeffrey.t.kirsher@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	pstaszewski@artcom.pl, stable@kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59474
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751812Ab0BHXOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 18:14:09 -0500
In-Reply-To: <alpine.WNT.2.00.1002081432390.6892@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Mon, 8 Feb 2010 15:06:24 -0800 (Pacific Standard Time)

>> > on 2.6.33-rc6-git5 i have this info:
> 
>> > BUG: soft lockup - CPU#1 stuck for 61s!
>> > [events/1:28]
> 
> so why is this events/1 thing here?

Jesse, this is taken care of already, see:

http://marc.info/?l=linux-netdev&m=126565759512718&w=2
