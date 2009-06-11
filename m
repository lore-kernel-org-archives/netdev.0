From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] de2104x: support for systems lacking cache
 coherence
Date: Thu, 11 Jun 2009 02:34:10 -0700 (PDT)
Message-ID: <20090611.023410.154368260.davem@davemloft.net>
References: <200906101955.n5AJt0Zr008180@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, risto.suominen@gmail.com,
	grundler@parisc-linux.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758956AbZFKJeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:34:08 -0400
In-Reply-To: <200906101955.n5AJt0Zr008180@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 10 Jun 2009 12:55:00 -0700

> From: Risto Suominen <risto.suominen@gmail.com>
> 
> Add a configurable Descriptor Skip Length for systems that lack cache
> coherence.
> 
> (akpm: I think this should be done as a module parameter, not a
> compile-tinme option)
> 
> Signed-off-by: Risto Suominen <Risto.Suominen@gmail.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
