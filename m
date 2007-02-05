From: akepner@sgi.com
Subject: Re: Extensible hashing and RCU
Date: Mon, 5 Feb 2007 10:02:53 -0800 (PST)
Message-ID: <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
References: <20070204074143.26312.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:58608 "EHLO omx2.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752632AbXBESMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 13:12:53 -0500
In-Reply-To: <20070204074143.26312.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 4 Feb 2007 linux@horizon.com wrote:

> I noticed in an LCA talk mention that apprently extensible hashing
> with RCU access is an unsolved problem.  Here's an idea for solving it.
> ....

Yes, I have been playing around with the same idea for
doing dynamic resizing of the TCP hashtable.

Did a prototype "toy" implementation, and I have a
"half-finished" patch which resizes the TCP hashtable
at runtime. Hmmm, your mail may be the impetus to get
me to finally finish this thing....

-- 
Arthur

