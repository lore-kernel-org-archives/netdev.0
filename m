From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] e1000e: Useset_memory_ro()/set_memory_rw() to
 protect flash memory
Date: Tue, 23 Sep 2008 16:47:45 -0700 (PDT)
Message-ID: <20080923.164745.12711639.davem@davemloft.net>
References: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>
	<20080923.162957.141669474.davem@davemloft.net>
	<Pine.LNX.4.64.0809240142030.27884@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org, mingo@elte.hu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	bruce.w.allan@intel.com
To: jkosina@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752363AbYIWXr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 19:47:57 -0400
In-Reply-To: <Pine.LNX.4.64.0809240142030.27884@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jkosina@suse.cz>
Date: Wed, 24 Sep 2008 01:45:53 +0200 (CEST)

> Yes, probably not a vanilla kernel material, but could be very well used 
> for testing to further isolate whether it is kernel or userspace 
> corrupting the memory mapped eeprom.

Absolutely.
