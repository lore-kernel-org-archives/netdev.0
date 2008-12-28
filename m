From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/11] benet: Kconfig, MAINTAINETS, drivers/net Makefile
Date: Sat, 27 Dec 2008 18:23:44 -0800 (PST)
Message-ID: <20081227.182344.188988811.davem@davemloft.net>
References: <20081227154151.c46a87cd@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathyap@serverengines.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, romieu@fr.zoreil.com, kaber@trash.net
To: subbus@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50632
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750810AbYL1CXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 21:23:42 -0500
In-Reply-To: <20081227154151.c46a87cd@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Subbu Seetharaman" <subbus@serverengines.com>
Date: Sat, 27 Dec 2008 07:41:51 -0800

> Do you still have objection to the use of the the macros to 
> calculate the offsets and shifts with the help of the pseudo 
> structure ratger than defining constants ?

I objected to the capitalized structure names et al.

You should make your driver more match the coding and
naming style used in the rest of the kernel.
