From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 16:50:43 +0200
Message-ID: <201106251650.43541.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-27-git-send-email-jeffrey.t.kirsher@intel.com> <201106251648.03574.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, Sriram <srk@ti.com>,
	Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:64327 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab1FYOut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:50:49 -0400
In-Reply-To: <201106251648.03574.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Arnd Bergmann wrote:
> >  drivers/net/{ => ethernet}/arm/ks8695net.c     |    0
> >  drivers/net/{ => ethernet}/arm/ks8695net.h     |    0
> >  drivers/net/{ => ethernet}/arm/w90p910_ether.c |    0
> 
> not sure about these.

Actually, you do have a directory for Micrel, so you you put
ks8695net.c together with ks88*.c.

	Arnd
