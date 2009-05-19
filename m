From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, v2] net: release dst entry in dev_hard_start_xmit()
Date: Mon, 18 May 2009 22:19:56 -0700 (PDT)
Message-ID: <20090518.221956.153457626.davem@davemloft.net>
References: <4A092F59.7020900@cosmosbay.com>
	<4A093178.9020105@cosmosbay.com>
	<4A09CD6B.5070604@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752118AbZESFT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 01:19:59 -0400
In-Reply-To: <4A09CD6B.5070604@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 12 May 2009 21:26:35 +0200

> [PATCH] net: release dst entry in dev_hard_start_xmit()
 ...
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.

Eric, please followup and double-check the pppoe paths
that Jarek mentioned.  I never saw that fully resolved.

Thanks!
