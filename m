From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] can: add can_free_echo_skb() for upcoming
 drivers
Date: Fri, 04 Sep 2009 02:13:50 -0700 (PDT)
Message-ID: <20090904.021350.234672852.davem@davemloft.net>
References: <4A9D3D14.90201@grandegger.com>
	<20090903.204641.193482962.davem@davemloft.net>
	<4AA0C692.5000003@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933051AbZIDJNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 05:13:35 -0400
In-Reply-To: <4AA0C692.5000003@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Fri, 04 Sep 2009 09:49:38 +0200

> David Miller wrote:
>> Can a CAN expert please review these patches?  They are rotting
>> in patchwork and I want to move forward with them somehow.I'
> 
> I'm maintaining the CAN device drivers interface and drivers as listed
> in MAINTAINERS. Though, these patches have already the official blessing.

My bad :-)  I'll apply these then.

> Do you want me to setup a git repository "can-next-2.6" where you can
> pull from? So far, not that much can-drv patches have been posted to
> this list.

You can do that in the future if you like, sure.  But it is not a
requirement, as with the rate you guys send things I am handling it
efficiently using patchwork.
