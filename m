From: David Miller <davem@davemloft.net>
Subject: Re: [LIB] pcounter : unline too big functions
Date: Thu, 03 Jan 2008 20:41:49 -0800 (PST)
Message-ID: <20080103.204149.26161606.davem@davemloft.net>
References: <20080103165227.02fc0da4.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59730
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753640AbYADElu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 23:41:50 -0500
In-Reply-To: <20080103165227.02fc0da4.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 3 Jan 2008 16:52:27 +0100

> Before pushing pcounter to Linus tree, I would like to make some adjustments.
> 
> Goal is to reduce kernel text size, by unlining too big functions.
...
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
