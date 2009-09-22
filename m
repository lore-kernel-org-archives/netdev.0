From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igb: resolve namespacecheck warning for
 igb_hash_mc_addr
Date: Mon, 21 Sep 2009 22:37:27 -0700 (PDT)
Message-ID: <20090921.223727.167119781.davem@davemloft.net>
References: <20090918005219.25329.94906.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754647AbZIVFhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 01:37:09 -0400
In-Reply-To: <20090918005219.25329.94906.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 Sep 2009 17:52:29 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch resolves a warning seen when doing namespace checking via
> "make namespacecheck"
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
