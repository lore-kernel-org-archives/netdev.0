From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] ipv4: netfilter: ip_tables: fix information leak
 to userland
Date: Wed, 03 Nov 2010 18:55:52 -0700 (PDT)
Message-ID: <20101103.185552.59666742.davem@davemloft.net>
References: <1288822372-21245-1-git-send-email-kaber@trash.net>
	<1288822372-21245-6-git-send-email-kaber@trash.net>
	<alpine.LNX.2.01.1011032355020.31351@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754411Ab0KDBz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 21:55:28 -0400
In-Reply-To: <alpine.LNX.2.01.1011032355020.31351@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Wed, 3 Nov 2010 23:55:58 +0100 (CET)

> netfilter: ip6_tables: fix information leak to userspace
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Good catch, applied, thanks Jan.
