From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSO
	frame   size
Date: Fri, 29 Feb 2008 22:11:41 +0100
Message-ID: <20080229211141.GB2848@ami.dom.local>
References: <20080228183150.4431.81252.stgit@localhost.localdomain> <20080229204650.GA2848@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:16165 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932738AbYB2VIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 16:08:34 -0500
Received: by ug-out-1314.google.com with SMTP id z38so502341ugc.16
        for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 13:08:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080229204650.GA2848@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 29, 2008 at 09:46:50PM +0100, Jarek Poplawski wrote:
...
> gso_max_size = 65536 >> GSO_MAX_SIZE_SHIFT
> 
> Then it seems 3 or 4 bits should be enough for this, and BTW, it looks

...Hm... 2 or 3 bits! 

Jarek P.
