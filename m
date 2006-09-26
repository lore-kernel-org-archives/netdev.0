From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Generic HDLC update
Date: Tue, 26 Sep 2006 17:38:59 -0400
Message-ID: <45199DF3.1050708@garzik.org>
References: <m3odt21hs5.fsf@defiant.localdomain> <m3ac4m1fbj.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	PC300 Maintainer <pc300@cyclades.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:30611 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964834AbWIZVjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 17:39:01 -0400
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3ac4m1fbj.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> The first patch renames drivers/net/wan/hdlc_generic.c file to hdlc.c.
> It has been generated with git-diff* -M. Please let me know if you
> need a "normal" patch.

It depends completely on what git-applymbox will accept, and how 
git-applymbox interprets your submission.

In this case... testing... it looks like it renamed things correctly.

	Jeff


