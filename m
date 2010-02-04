From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] e1000: Report link status in ethtool
 when interface is down
Date: Wed, 03 Feb 2010 19:47:17 -0800 (PST)
Message-ID: <20100203.194717.245921685.davem@davemloft.net>
References: <20100204004926.16084.32526.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	nicholasx.d.nunley@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756285Ab0BDDrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:47:03 -0500
In-Reply-To: <20100204004926.16084.32526.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 16:49:28 -0800

> From: Nick Nunley <nicholasx.d.nunley@intel.com>
> 
> With this change ethtool will correctly report link status when
> the interface is down. Currently ethtool reports the link as not
> detected when the interface is down.
> 
> Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
