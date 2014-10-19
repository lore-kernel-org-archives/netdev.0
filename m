From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 0/3] net: minor gso encapsulation fixes
Date: Sun, 19 Oct 2014 22:55:11 +0200
Message-ID: <20141019205511.GB4626@breakpoint.cc>
References: <1413751340-19621-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41358 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751702AbaJSUzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 16:55:14 -0400
Received: from fw by Chamillionaire.breakpoint.cc with local (Exim 4.80)
	(envelope-from <fw@strlen.de>)
	id 1XfxVP-0002k9-Pv
	for netdev@vger.kernel.org; Sun, 19 Oct 2014 22:55:11 +0200
Content-Disposition: inline
In-Reply-To: <1413751340-19621-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> wrote:
> The following series fixes a minor bug in the gro segmentation handlers
> when handling encapsulation offloads.

In case you're wondering, 'is there a 4th patch in this series'?

There was, I intentionally did not send it (IMO its -next material)
but forgot to adjust the "PATCH x/y" part of the subject lines.
