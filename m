From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 22:23:12 +0200
Message-ID: <20130723202312.GA31567@electric-eye.fr.zoreil.com>
References: <4961229.bXDGvH0dpz@al>
 <51EE75A1.3070804@cogentembedded.com>
 <1765554.SGJMeyexPP@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51209 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934264Ab3GWUX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 16:23:27 -0400
Content-Disposition: inline
In-Reply-To: <1765554.SGJMeyexPP@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
> This message was added in commit a7154cb8 (June 2004, [PATCH] r8169:
> link handling and phy reset rework) and is printed every ten seconds
> when no cable is connected.
+                            and runtime power management is disabled.

It isn't completely academic: Fedora has it enabled.

You have the implicit ack of David, so please keep the facts right.

-- 
Ueimor
