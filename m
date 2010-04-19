From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8842: Add module param for setting mac address
Date: Sun, 18 Apr 2010 23:36:31 -0700 (PDT)
Message-ID: <20100418.233631.115927208.davem@davemloft.net>
References: <1271611557.24099.11.camel@debian>
	<20100418.211800.112605815.davem@davemloft.net>
	<4BCBF53D.1040800@pelagicore.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37945
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751018Ab0DSGg0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 02:36:26 -0400
In-Reply-To: <4BCBF53D.1040800@pelagicore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Mon, 19 Apr 2010 08:16:29 +0200

> I posted a new patch where the MAC address is passed via
> platform data, hope that's an accepted way.

I saw also that you mentioned that there is no real
way to probe this information.

Therefore I worry that your plan might be to simply
use some kernel command line or module option somewhere
else to fill in this platform_device value.

Is that what you plan to do?
