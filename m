From: Philippe De Muyter <phdm@macqel.be>
Subject: Re: [PATCH] net : make netlink_seq_ops const
Date: Fri, 6 Jul 2007 15:24:23 +0200
Message-ID: <20070706132423.GA10767@ingate.macqel.be>
References: <20070706124829.GA12930@muff.macqel.be> <468E3AFB.7060403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.macqel.be ([194.78.208.39]:12330 "EHLO mail.macqel.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbXGFNYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 09:24:25 -0400
Content-Disposition: inline
In-Reply-To: <468E3AFB.7060403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 06, 2007 at 02:52:11PM +0200, Patrick McHardy wrote:
> [please send networking patches to netdev]
> 
> Philippe De Muyter wrote:
> > Hi all,
> > 
> > Make netlink_seq_ops const
> 
> 
> Might make more sense to do a big patch for all occurences of this
> in net/:
> 
> # grep "^static struct seq_operations" -r net/ | wc -l
> 76

OK

Philippe
