From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 14:16:07 -0400
Message-ID: <20090519181607.GE28034@hmsreliant.think-freely.org>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com> <20090519162330.GC28034@hmsreliant.think-freely.org> <20090519171703.GA2749@ami.dom.local> <20090519174504.GD28034@hmsreliant.think-freely.org> <20090519180505.GB2981@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, lav@yar.ru,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43882 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbZESSQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 14:16:22 -0400
Content-Disposition: inline
In-Reply-To: <20090519180505.GB2981@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 08:05:05PM +0200, Jarek Poplawski wrote:
> On Tue, May 19, 2009 at 01:45:04PM -0400, Neil Horman wrote:
> ...
> > I'm unable to find the move to front heuristic that you mentioned creates furthe
> > list disordering. [...]
> 
> I'd only like to make it clear the analysis you refer to is by
> Alexander V. Lukyanov <lav@yar.ru>
> 
Ok, thank you for giving credit where its due :).  Alexander, can you point out
the location of the move-to-front heruistic that you mention in your analysis?

Neil

> Jarek P.
> 
