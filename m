From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [TCP]: Reorganize tcp_sock to fill 64-bit holes &
 improve locality
Date: Thu, 29 May 2008 03:26:24 -0700 (PDT)
Message-ID: <20080529.032624.193694741.davem@davemloft.net>
References: <Pine.LNX.4.64.0805211534170.16829@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0805211536390.16829@wrl-59.cs.helsinki.fi>
	<483B9F2A.8070804@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52614
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751070AbYE2K02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 06:26:28 -0400
In-Reply-To: <483B9F2A.8070804@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 27 May 2008 07:42:02 +0200

> Thanks Ilpo for this work. This looks very good.
> 
> Sorry for my delayed answer.
> 
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied and I'll push out to net-next-2.6 after some test
builds.

Thanks!
