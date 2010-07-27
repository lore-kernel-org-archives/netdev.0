From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] igb: restore EEPROM values of MDICNFG
 on reset with 82580
Date: Mon, 26 Jul 2010 18:43:40 -0700 (PDT)
Message-ID: <20100726.184340.212677932.davem@davemloft.net>
References: <20100726231456.23941.67606.stgit@localhost.localdomain>
	<20100726231526.23941.23179.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	nicholas.d.nunley@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37566
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753263Ab0G0BnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 21:43:23 -0400
In-Reply-To: <20100726231526.23941.23179.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Jul 2010 16:15:29 -0700

> From: Nick Nunley <nicholas.d.nunley@intel.com>
> 
> On a reset the MDICNFG.Destination and MDICNFG.COM_MDIO
> register fields are not restored to the EEPROM default.
> This patch modifies the reset code to read the EEPROM
> and restore the default values.
> 
> Signed-off-by: Nicholas Nunley <nicholas.d.nunley@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
