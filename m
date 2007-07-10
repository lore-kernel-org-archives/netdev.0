From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: ata and netdev (was Re: -mm merge plans for 2.6.23)
Date: Tue, 10 Jul 2007 13:35:19 -0700
Message-ID: <20070710133519.739ad282.akpm@linux-foundation.org>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<4693C4F8.40903@garzik.org>
	<20070710112458.e9dbb55e.akpm@linux-foundation.org>
	<4693EC9B.6020305@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60493 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757125AbXGJUkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 16:40:33 -0400
In-Reply-To: <4693EC9B.6020305@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007 00:31:23 +0400
Sergei Shtylyov <sshtylyov@ru.mvista.com> wrote:

> Hello.
> 
> Andrew Morton wrote:
> 
> > 3x59x-fix-pci-resource-management.patch: you wrote it ;) I have a comment
> 
>     No, I did, almost a year ago already. :-)

I thought that was odd.  I fixed the attribution.
 
> > here:
> 
> > - I don't remember the story with cardbus either.  Presumably once upon a
> >   time the cardbus layer was claiming IO regions on behalf of cardbus
> >   devices (?)
> 
>     IIRC, that's your own comment.

yup, that's what "I have a comment" meant ;)

The comment seems rather bogus actually.  Let's just merge it.

