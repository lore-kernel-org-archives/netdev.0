From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: cleanup ethtool autoneg input
Date: Tue, 27 Apr 2010 09:56:29 -0700 (PDT)
Message-ID: <20100427.095629.191403481.davem@davemloft.net>
References: <20100427112513.24196.70511.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52189
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751451Ab0D0Q4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 12:56:24 -0400
In-Reply-To: <20100427112513.24196.70511.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is also not appropriate for net-2.6, it doesn't fix a
regression in the regression list and it doesn't fix a catastropic
crash or failure.

You really have to be kidding me if you thing a patch like this
is fine this late in the -RC series.

You also aren't even numbering your patches, which is quite a
transgression when a submission of a set of patches all to the same
driver and/or files.
