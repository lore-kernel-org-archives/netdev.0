From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Batched netns improvements.
Date: Thu, 03 Dec 2009 12:24:06 -0800 (PST)
Message-ID: <20091203.122406.203286092.davem@davemloft.net>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, dlezcano@fr.ibm.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54517
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962AbZLCUX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:23:59 -0500
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 03 Dec 2009 04:27:08 -0800

> 
> This series of patches takes my simple 4k network namespace exit test
> from about 44s to 1.6s, with a minuscule increase in code side.
> 
> While batching has given me big improvements there are a few
> changes in there that improve the performance of cleaning up
> a single network namespace.

All applied to net-next-2.6, thanks Eric.
