From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Generic PHY lib vs. locking
Date: Fri, 29 Dec 2006 07:22:10 +1100
Message-ID: <1167337330.23340.64.camel@localhost.localdomain>
References: <1166760473.6673.85.camel@localhost.localdomain>
	 <34B0D342-2B8E-4BF8-A568-7071D3695FB0@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58033 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754944AbWL1UWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Dec 2006 15:22:16 -0500
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <34B0D342-2B8E-4BF8-A568-7071D3695FB0@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Great!  At last glance, only gianfar, fs_enet, and au1000_eth.  There  
> are one or two others that haven't gone in, yet.  My hope is that  
> your changes will not require any changes to the drivers, but I'll  
> leave that to your discretion.

Unfortunately, it will probably have an impact on them. I'll have a
look.

Ben.


