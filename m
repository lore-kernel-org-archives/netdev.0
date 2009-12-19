From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: LED settings in EEPROM ignored on
 82571 and 82572
Date: Fri, 18 Dec 2009 20:15:08 -0800 (PST)
Message-ID: <20091218.201508.246530153.davem@davemloft.net>
References: <20091218014214.4948.26355.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755960AbZLSEPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:15:06 -0500
In-Reply-To: <20091218014214.4948.26355.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 Dec 2009 17:42:15 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Do not override the customizable LED configuration set in the EEPROM.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
