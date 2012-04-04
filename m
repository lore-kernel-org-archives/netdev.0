From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] Implement IP_EVIL socket option (RFC 3514)
Date: Wed, 4 Apr 2012 21:18:21 +0100
Message-ID: <20120404201821.GC6589@ZenIV.linux.org.uk>
References: <1333284791-5363-1-git-send-email-martin@lucina.net>
 <87r4w3nw7n.fsf@mid.deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Lucina <martin@lucina.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Florian Weimer <fw@deneb.enyo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34088 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115Ab2DDUSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 16:18:23 -0400
Content-Disposition: inline
In-Reply-To: <87r4w3nw7n.fsf@mid.deneb.enyo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 04, 2012 at 09:17:00PM +0200, Florian Weimer wrote:
> * Martin Lucina:
> 
> > This patch implements the IP_EVIL socket option, allowing user-space
> > applications to set the Security Flag in the IPv4 Header, aka "evil" bit,
> > as defined in RFC 3514.
> 
> I need this to fix a security issue.  Could this be merged for real,
> please?

I would suggest switching away from your RFC1149 link - looks like your mail
took 3 days on the way out...
