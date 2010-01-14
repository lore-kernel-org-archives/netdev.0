From: Joe Perches <joe@perches.com>
Subject: Re: netdev: patchwork.ozlabs.org vs patchwork.kernel.org ?
Date: Wed, 13 Jan 2010 17:49:04 -0800
Message-ID: <1263433744.1966.52.camel@Joe-Laptop.home>
References: <3DBBD805E3BA064A87F551C0E8BD36740289748A@MAILSRV.intcomgrp.com>
	 <20100113.173253.223656114.davem@davemloft.net>
	 <1263433237.1966.37.camel@Joe-Laptop.home>
	 <20100113.174141.169192840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1157 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752264Ab0ANBtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2010 20:49:05 -0500
In-Reply-To: <20100113.174141.169192840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-01-13 at 17:41 -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 13 Jan 2010 17:40:37 -0800
> > On Wed, 2010-01-13 at 17:32 -0800, David Miller wrote:
> >> Encoding your patches as base64 binary octet stream attachments
> >> causes them to get missed by our automated patch tracking system:
> >> 	http://patchwork.ozlabs.org/project/netdev/list/
> > What is the reason why netdev doesn't use patchwork.kernel.org?
> > It seems odd that it doesn't.  Odd like the arm mailing lists.
> ozlabs was the original, and so just like powerpc port that's where we
> started using the tool.
> I honestly don't care where it's hosted.

Neither do I, but it might be nice to put a link
to the patchwork.ozlabs.org queues on this page

http://patchwork.kernel.org/

(or the other way 'round, or both)

so there's a centralized listing of all linux related
patchwork queues.


