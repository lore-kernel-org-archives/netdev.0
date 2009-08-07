From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 3x59x-fix-pci-resource-management.patch
Date: Fri, 7 Aug 2009 09:14:15 -0700
Message-ID: <20090807091415.6a78af4d.akpm@linux-foundation.org>
References: <20090806154223.b9b9759e.akpm@linux-foundation.org>
	<4A7C079D.8010505@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44483 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753808AbZHGQPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 12:15:15 -0400
In-Reply-To: <4A7C079D.8010505@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Aug 2009 14:53:17 +0400 Sergei Shtylyov <sshtylyov@ru.mvista.com> wrote:

> Hello.
> 
> Andrew Morton wrote:
> 
> > Guys, I seem to have been sitting on the below patch for, err, three years.
> 
> > I generally do this because there's some issue which needs to be
> > addressed, but the patch didn't address it right.
> 
>     In this case it was different: you just wanted the patch to be verifed 
> on an EISA card...
> 
> On Mon, 14 Aug 2006 14:31:46 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>  >> ACK, shall I apply this to netdev#upstream ?
> 
> Spose so, but let's not go mainline until I've had a chance to test an
> EISA card and a cardbus card.
> 
>     There was several more comments from you but they all got resolved 
> between you and Jeff at the time...
> 

Doh, OK, thanks.  My fault.

I have a cardbus card somewhere..
