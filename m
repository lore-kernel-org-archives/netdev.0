From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] net: fs_enet: use swap() in
 fs_enet_rx_napi()
Date: Thu, 11 Jun 2015 15:21:25 -0700 (PDT)
Message-ID: <20150611.152125.2297229639938532767.davem@davemloft.net>
References: <1433953999-24740-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Julia.Lawall@lip6.fr,
	pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbbFKWV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 18:21:26 -0400
In-Reply-To: <1433953999-24740-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 10 Jun 2015 18:33:19 +0200

> Use kernel.h macro definition.
> 
> Thanks to Julia Lawall for Coccinelle scripting support.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
