From: David Miller <davem@davemloft.net>
Subject: Re: [atl1-devel] atl2: don't mess up irq on suspend/resume
 (probably msi only)
Date: Thu, 20 Nov 2008 04:18:33 -0800 (PST)
Message-ID: <20081120.041833.149786906.davem@davemloft.net>
References: <20081119183443.7ca1cf23@osprey.hogchain.net>
	<20081120.014420.256210031.davem@davemloft.net>
	<20081120053329.1722745f@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: atl1-devel@lists.sourceforge.net, alan-jenkins@tuffmail.co.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752589AbYKTMSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:18:33 -0500
In-Reply-To: <20081120053329.1722745f@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jcliburn@gmail.com>
Date: Thu, 20 Nov 2008 05:33:29 -0600

> On Thu, 20 Nov 2008 01:44:20 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Jay Cliburn <jcliburn@gmail.com>
> > Date: Wed, 19 Nov 2008 18:34:43 -0600
> > 
> > > Can someone tell before I submit this patch if the description is
> > > sane?
> > > 
> > > atl2: don't request irq on resume if netif running
> > 
> > It looks good, mind if I just apply this as-is?
> 
> Yes please.  Go right ahead.  Thanks.

Done.
