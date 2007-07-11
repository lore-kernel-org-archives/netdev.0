From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Virtual ethernet device (v2.1)
Date: Wed, 11 Jul 2007 13:45:04 -0700 (PDT)
Message-ID: <20070711.134504.126764586.davem@davemloft.net>
References: <4694A363.2070406@openvz.org>
	<200707111254.24352.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, kaber@trash.net, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com, greearb@candelatech.com, devel@openvz.org,
	dev@openvz.org
To: borntraeger@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757652AbXGKUol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 16:44:41 -0400
In-Reply-To: <200707111254.24352.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Wed, 11 Jul 2007 12:54:24 +0200

> Am Mittwoch, 11. Juli 2007 schrieb Pavel Emelianov:
> >  drivers/net/veth.c   |  452 
> >  include/net/veth.h   |   14 +
> 
> I know, I am late in the game, but wont the name collide somewhat with 
> drivers/net/ibmveth.h, drivers/net/iseries_veth.c, and drivers/net/ibmveth.c?

We discussed that and decided that it's not an issue.
