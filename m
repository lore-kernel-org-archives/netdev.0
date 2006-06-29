From: James Morris <jmorris@namei.org>
Subject: Re: RDMA will be reverted
Date: Thu, 29 Jun 2006 16:42:35 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606291642010.26501@d.namei>
References: <20060628.000715.95062023.davem@davemloft.net>  <adawtazgawi.fsf@cisco.com>
  <20060629.124628.88476747.davem@davemloft.net> <1151611866.11739.57.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:4771 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932462AbWF2Umi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:42:38 -0400
To: Tom Tucker <tom@opengridcomputing.com>
In-Reply-To: <1151611866.11739.57.camel@trinity.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Jun 2006, Tom Tucker wrote:

> On Thu, 2006-06-29 at 12:46 -0700, David Miller wrote:
> > From: Roland Dreier <rdreier@cisco.com>
> > Date: Thu, 29 Jun 2006 09:54:37 -0700
> > 
> > > In any case I think we need to find a way for Linux to support iWARP
> > > hardware, since there are users that want this, and (some of) the
> > > vendors are working hard to do things the right way (including cc'ing
> > > netdev on the conversation).  I don't think it's good for Linux for
> > > the answer to just be, "sorry, you're wrong to want to use that hardware."
> > 
> > We give the same response for TOE stuff.
> 
> What does the word "we" represent in this context? Is it the Linux
> community at large, Linux and Andrew, you? I'm not trying to be
> argumentative, I just want to understand how carefully and by whom iWARP
> technology has been considered.

$ grep -ri davem /usr/src/linux



- James
-- 
James Morris
<jmorris@namei.org>
