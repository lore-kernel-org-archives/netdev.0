From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 14:54:34 -0700 (PDT)
Message-ID: <20070612.145434.101481280.davem@davemloft.net>
References: <466F0D78.7090404@candelatech.com>
	<20070612.142658.45082832.davem@davemloft.net>
	<466F144A.3070809@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, kaber@trash.net,
	hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752584AbXFLVyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 17:54:18 -0400
In-Reply-To: <466F144A.3070809@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 12 Jun 2007 14:46:50 -0700

> And, since the mac-vlan can work as pure software on top of any NIC that
> can go promisc and send with arbitrary source MAC, it will already work
> with virtually all wired ethernet devices currently in existence.

Absolutely, I'm not against something like mac-vlan at all.
