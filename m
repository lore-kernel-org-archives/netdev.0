From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net-sched 00/06: dynamically sized class hashes v2
Date: Thu, 3 Jul 2008 18:14:03 +0200
Message-ID: <20080703161403.GA2637@ami.dom.local>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:50070 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbYGCQMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 12:12:48 -0400
Received: by wa-out-1112.google.com with SMTP id j37so552080waf.23
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2008 09:12:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 05:16:01PM +0200, Patrick McHardy wrote:
...
> The patches need the two filter destruction fixes that went into
> net-2.6.git to apply cleanly, so they won't apply until net-2.6.git
> is merged into net-next-2.6.git.

Patrick, I just was about to write that some patches (1, 3, 5) give
checkpatch warnings... (but no big deal).

I'll try to look at this later, but let's say: if I don't write
means I'm OK with all these patches.

Thanks again,
Jarek P.

BTW: I wonder why cbq and htb have "common", while hfsc "cl_common"?
