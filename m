From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/7] ICMP: drop unused MIB accounting wrappers
Date: Mon, 14 Jul 2008 23:02:15 -0700 (PDT)
Message-ID: <20080714.230215.227106647.davem@davemloft.net>
References: <4871F2D8.8030502@openvz.org>
	<4871F4FE.3050509@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56772
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754698AbYGOGCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 02:02:15 -0400
In-Reply-To: <4871F4FE.3050509@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 07 Jul 2008 14:50:38 +0400

> There are ICMP_XXX_STATS that are not used in the kernel, so I remove
> them, not to "just patch" them later. But if there's some sense in 
> keeping them, kick me - I will remake this set keeping them.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
