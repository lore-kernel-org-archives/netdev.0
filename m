From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [atl1-devel] atl2: don't mess up irq on suspend/resume
 (probably msi only)
Date: Thu, 20 Nov 2008 05:33:29 -0600
Message-ID: <20081120053329.1722745f@osprey.hogchain.net>
References: <4922FD09.2070007@tuffmail.co.uk>
	<49231CCB.8010900@tuffmail.co.uk>
	<20081119183443.7ca1cf23@osprey.hogchain.net>
	<20081120.014420.256210031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: atl1-devel@lists.sourceforge.net, alan-jenkins@tuffmail.co.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.240]:55513 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755993AbYKTLdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 06:33:36 -0500
Received: by hs-out-0708.google.com with SMTP id 4so195685hsl.5
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 03:33:34 -0800 (PST)
In-Reply-To: <20081120.014420.256210031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Nov 2008 01:44:20 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Jay Cliburn <jcliburn@gmail.com>
> Date: Wed, 19 Nov 2008 18:34:43 -0600
> 
> > Can someone tell before I submit this patch if the description is
> > sane?
> > 
> > atl2: don't request irq on resume if netif running
> 
> It looks good, mind if I just apply this as-is?

Yes please.  Go right ahead.  Thanks.
