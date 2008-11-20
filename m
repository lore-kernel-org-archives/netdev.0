From: David Miller <davem@davemloft.net>
Subject: Re: atl2: don't mess up irq on suspend/resume (probably msi only)
Date: Thu, 20 Nov 2008 01:44:20 -0800 (PST)
Message-ID: <20081120.014420.256210031.davem@davemloft.net>
References: <4922FD09.2070007@tuffmail.co.uk>
	<49231CCB.8010900@tuffmail.co.uk>
	<20081119183443.7ca1cf23@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan-jenkins@tuffmail.co.uk, atl1-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	csnook@redhat.com
To: jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbYKTJoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:44:20 -0500
In-Reply-To: <20081119183443.7ca1cf23@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jcliburn@gmail.com>
Date: Wed, 19 Nov 2008 18:34:43 -0600

> Can someone tell before I submit this patch if the description is sane?
> 
> atl2: don't request irq on resume if netif running

It looks good, mind if I just apply this as-is?

Thanks.
