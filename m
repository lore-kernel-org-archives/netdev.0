From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: xfrm_algo_clone() allocates too much memory
Date: Tue, 08 Jan 2008 23:53:52 -0800 (PST)
Message-ID: <20080108.235352.252168303.davem@davemloft.net>
References: <478477C7.9030004@cosmosbay.com>
	<20080108.234012.181072357.davem@davemloft.net>
	<47847D0B.3050003@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56129
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750903AbYAIHxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:53:53 -0500
In-Reply-To: <47847D0B.3050003@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 09 Jan 2008 08:51:39 +0100

> Yes I have a patch for these divides, but will apply on 2.6.25 once this one 
> hits it.  (this saves 192 bytes of kernel text BTW)

I never doubted you for a second.

