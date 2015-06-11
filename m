From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] vxge: use swap() in
 vxge_hw_channel_dtr_alloc()
Date: Thu, 11 Jun 2015 15:21:19 -0700 (PDT)
Message-ID: <20150611.152119.673716875456460927.davem@davemloft.net>
References: <1433954006-24799-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Julia.Lawall@lip6.fr,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbbFKWVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 18:21:20 -0400
In-Reply-To: <1433954006-24799-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 10 Jun 2015 18:33:26 +0200

> Use kernel.h macro definition.
> 
> Thanks to Julia Lawall for Coccinelle scripting support.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
