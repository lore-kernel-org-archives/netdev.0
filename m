From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: init_vlan should not copy slave or master
 flags
Date: Wed, 02 Jun 2010 03:35:45 -0700 (PDT)
Message-ID: <20100602.033545.176662933.davem@davemloft.net>
References: <20100513073106.3528.45412.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, fubar@us.ibm.com, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34563
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757146Ab0FBKff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 06:35:35 -0400
In-Reply-To: <20100513073106.3528.45412.stgit@jf-dev2-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Thu, 13 May 2010 00:31:06 -0700

> The vlan device should not copy the slave or master flags from
> the real device. It is not in the bond until added nor is it
> a master.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks John.
