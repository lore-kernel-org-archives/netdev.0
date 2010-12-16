From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/2] bonding: generic netlink infrastructure
Date: Thu, 16 Dec 2010 14:06:55 -0800 (PST)
Message-ID: <20101216.140655.35050321.davem@davemloft.net>
References: <1292278055-2842-1-git-send-email-fubar@us.ibm.com>
	<1292278055-2842-2-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753238Ab0LPWG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:06:26 -0500
In-Reply-To: <1292278055-2842-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 13 Dec 2010 14:07:34 -0800

> -bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
> +bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_netlink.o

The new bond_netlink.c file is missing from the patch.

Forgotten "git add" most likely. :-)

