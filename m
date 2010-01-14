From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] e1000e: use alternate MAC address on
 ESB2 if available
Date: Wed, 13 Jan 2010 20:32:06 -0800 (PST)
Message-ID: <20100113.203206.226471517.davem@davemloft.net>
References: <20100113120416.23715.64354.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38005
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751292Ab0ANEb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 23:31:57 -0500
In-Reply-To: <20100113120416.23715.64354.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 Jan 2010 04:04:58 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Similar to 82571/2/3 parts that already do this, if ESB2/80003es2lan parts
> have an alternate MAC address provided in the EEPROM use it instead of the
> default MAC address.  This patch makes the the actual code that does this
> generic so that it can be better used by both MAC families.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
