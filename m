From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Fix mglist corruption that leads to memory corruption
Date: Fri, 11 Feb 2011 21:59:50 -0800 (PST)
Message-ID: <20110211.215950.242150902.davem@davemloft.net>
References: <20110211223655.GA5585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ihands@redhat.com, jbacik@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48293
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751129Ab1BLF7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 00:59:14 -0500
In-Reply-To: <20110211223655.GA5585@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 12 Feb 2011 09:36:55 +1100

> This patch fixes a nasty memory corruption issue.
> 
> bridge: Fix mglist corruption that leads to memory corruption

Applied.
