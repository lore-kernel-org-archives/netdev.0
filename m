From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PING^2] [PATCH] srandom32 fixes for networking
Date: Wed, 2 Apr 2008 09:50:11 +0200
Message-ID: <20080402075011.GL29105@one.firstfloor.org>
References: <20080401113408.GA625@basil.nowhere.org> <20080402.001824.161259886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49047 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbYDBHqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 03:46:21 -0400
Content-Disposition: inline
In-Reply-To: <20080402.001824.161259886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2008 at 12:18:24AM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 1 Apr 2008 13:34:08 +0200
> 
> > Still missing from net-2.6.26
> > 
> > http://marc.info/?l=linux-netdev&m=120519912215170&w=2
> > 
> > Please add or justify rejection.
> 
> Please fix this patch so that the arch/x86/mm/pageattr-test.c
> build doesn't get broken by it.

Can you send me your config please? I don't see any build problem
here with the patch on top of -rc7-git something on either i386 nor x86-64.

-Andi
> 
