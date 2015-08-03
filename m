From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] fddi: Use a more more typical logging style
Date: Mon, 03 Aug 2015 16:20:54 -0700
Message-ID: <1438644054.4601.27.camel@perches.com>
References: <1438576065.30149.7.camel@perches.com>
	 <20150803.160515.553677819137228534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0026.hostedemail.com ([216.40.44.26]:50524 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932193AbbHCXVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 19:21:01 -0400
In-Reply-To: <20150803.160515.553677819137228534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-03 at 16:05 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sun, 02 Aug 2015 21:27:45 -0700
> 
> > Use macros that don't require fixed argument counts so
> > format and arguments can be verified by the compiler.
> > 
> > Miscellanea:
> > 
> > o Remove a few #if uses to allow dynamic debug to always work
> > o whitespace neatening
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> This doesn't apply cleanly to net-next, please respin.

Apologies for that.  I used a newer version of the
Evolution email client (3.16.0) which corrupts tabs.
3.16.3 doesn't seem to do that.

I'll probably downgrade back to the old 3.12 version
though.  It doesn't send some attachments properly,
but the editor at least works well.
