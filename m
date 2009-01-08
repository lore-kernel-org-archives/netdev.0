From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] vlan: add neigh_setup
Date: Thu, 08 Jan 2009 10:50:30 -0800 (PST)
Message-ID: <20090108.105030.229991099.davem@davemloft.net>
References: <20090107121550.878339000@de.ibm.com>
	<20090107121659.385897000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754738AbZAHSu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:50:29 -0500
In-Reply-To: <20090107121659.385897000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Wed, 07 Jan 2009 13:15:51 +0100

> In case the real device has a neigh_setup function, this
> neigh_setup function should be used for the vlan device.
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

This looks fine, applied.
