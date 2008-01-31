From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.25 is no more...
Date: Wed, 30 Jan 2008 16:36:55 -0800 (PST)
Message-ID: <20080130.163655.193708266.davem@davemloft.net>
References: <47A03D4D.5090301@fr.ibm.com>
	<20080130.054807.182676684.davem@davemloft.net>
	<47A0B62D.3080005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756935AbYAaAgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 19:36:36 -0500
In-Reply-To: <47A0B62D.3080005@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 30 Jan 2008 18:38:53 +0100

> David Miller wrote:
> > From: Daniel Lezcano <dlezcano@fr.ibm.com>
> > Date: Wed, 30 Jan 2008 10:03:09 +0100
> > 
> >> David Miller wrote:
> >>> Now that the bulk has been merged over and we are
> >>> actively working alongside Linus's tree I have moved
> >>> all current patch applying to net-2.6 instead of net-2.6.25,
> >>> so the current tree to use is:
> >>>
> >>> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
> >> This tree is for fixes only, right ? or shall we send enhancement 
> >> patches to net-2.6 until net-2.6.26 appears ?
> > 
> > The latter.
> 
> What will happen to the patches sent to net-2.6.25 a few days ago during 
> the merge ? Should I resend them against net-2.6 ?

I have them in my backlog, so just be patient as even just doing
a read-only pass on my email while being here at LCA08 is super
painful.
