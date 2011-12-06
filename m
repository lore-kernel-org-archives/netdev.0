From: David Miller <davem@davemloft.net>
Subject: Re: Patch is wrong
Date: Tue, 06 Dec 2011 00:25:43 -0500 (EST)
Message-ID: <20111206.002543.601828580754067320.davem@davemloft.net>
References: <4EDD8B8C.7000905@linux.vnet.ibm.com>
	<20111205.233937.1669740069700653317.davem@davemloft.net>
	<4EDDA413.1080106@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxram@us.ibm.com, fbl@redhat.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: wangyun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab1LFFZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:25:53 -0500
In-Reply-To: <4EDDA413.1080106@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Wang <wangyun@linux.vnet.ibm.com>
Date: Tue, 06 Dec 2011 13:11:47 +0800

> I know it will cost you many works, but I still have to ask you to
> replace this patch, because this will become a mistake in Linux, which
> will make me sad each time I saw it on git log.

It is simply not possible without screwing over every single person
who follows my tree.

If I go in and pull out the change, then everyone who follows my
tree will have a corrupt tree.

Sorry, mistakes happen, and once they are pushed out to GIT trees
used by lots of people we have to live with it.
