From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] xfrm: select sane defaults for xfrm[4|6] gc_thresh
Date: Fri, 31 Jul 2009 07:48:24 -0400
Message-ID: <20090731114824.GA18303@hmsreliant.think-freely.org>
References: <20090730.142345.148651785.davem@davemloft.net> <20090730.142554.103113174.davem@davemloft.net> <20090731011130.GA16769@localhost.localdomain> <20090730.185316.110755605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52488 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbZGaLsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 07:48:33 -0400
Content-Disposition: inline
In-Reply-To: <20090730.185316.110755605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2009 at 06:53:16PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu, 30 Jul 2009 21:11:30 -0400
> 
> > Ok, version 2. I'm not sure exactly what went wrong, but I definately had it
> > built and running.
> 
> As I said in my other email, the original patch does build and it
> probably runs too, it's just the warnings that you definitely didn't
> notice in the build at all.
> 
> I've apply this new version, thanks.
> 

Ah, that would explain it.  Thanks for the update!
Neil

