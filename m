From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: many sockets, slow sendto
Date: Thu, 22 Mar 2007 07:43:52 +0100
Message-ID: <20070322074352.56e3ae2d.dada1@cosmosbay.com>
References: <4600592E.80605@fw.hu>
	<460064C6.5030302@cosmosbay.com>
	<4601ADD8.8040500@cosmosbay.com>
	<20070321.181510.104045031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zacco@fw.hu, baruch@ev-en.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.cosmosbay.com ([86.65.150.131]:45515 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752654AbXCVGoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 02:44:07 -0400
In-Reply-To: <20070321.181510.104045031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Mar 2007 18:15:10 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 21 Mar 2007 23:12:40 +0100
> 
> > I chose in this patch to hash UDP sockets with a hash function that take into 
> > account both their port number and address : This has a drawback because we 
> > need two lookups : one with a given address, one with a wildcard (null) address.
> 
> Thanks for doing this work Eric, I'll review this when I get home
> tomorrow night or Friday.
> 

You're welcome :)

I knew you were busy with this new wii game^Wprogram

:)
