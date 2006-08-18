From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: restrict device names from having whitespace
Date: Thu, 17 Aug 2006 23:36:44 -0700 (PDT)
Message-ID: <20060817.233644.97293084.davem@davemloft.net>
References: <20060818022057.GA27076@nostromo.devel.redhat.com>
	<44E68C4E.8070607@osdl.org>
	<20060817231127.6438324e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xavier.bestel@free.fr, 7eggert@gmx.de, cate@debian.org,
	7eggert@elstempel.de, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39127
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750706AbWHRGgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 02:36:33 -0400
To: shemminger@osdl.org
In-Reply-To: <20060817231127.6438324e@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 17 Aug 2006 23:11:27 -0700

> Don't allow spaces in network device names because it makes
> it difficult to provide text interfaces via sysfs.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I have a patch which does this in my tree already Stephen.
