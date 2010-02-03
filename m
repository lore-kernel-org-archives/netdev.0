From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Wed, 3 Feb 2010 22:01:06 +0200
Message-ID: <20100203200105.GA5638@x200>
References: <1265130426.2861.158.camel@tonnant>
 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
 <1265134598.2861.191.camel@tonnant>
 <4B6870AF.6060109@trash.net>
 <4B6967BC.600@trash.net>
 <1265222289.2861.290.camel@tonnant>
 <20100203190948.GA5182@x200>
 <1265226227.2861.302.camel@tonnant>
 <20100203195153.GA5576@x200>
 <1265226838.2861.307.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:35935 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806Ab0BCUBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 15:01:13 -0500
Content-Disposition: inline
In-Reply-To: <1265226838.2861.307.camel@tonnant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2010 at 02:53:58PM -0500, Jon Masters wrote:
> > As a developer you fire a debugger and look at net_namespace_list.
> 
> Yeah, but being able to cat a nice file is always handy.

And what do you want to see at it?
