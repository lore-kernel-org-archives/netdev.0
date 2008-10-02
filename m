From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCHv2 1/2] [NET] add skb_recycle_check() to enable netdriver skb recycling
Date: Thu, 2 Oct 2008 11:17:38 +0400
Message-ID: <20081002071738.GC20406@2ka.mipt.ru>
References: <20080928204633.GB19070@xi.wantstofly.org> <20080928213824.GA25298@2ka.mipt.ru> <20080928215035.GG19070@xi.wantstofly.org> <20080929053931.GB21663@2ka.mipt.ru> <20080929094650.GA26097@xi.wantstofly.org> <20080929143327.GA27601@2ka.mipt.ru> <20080930030836.GE3251@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ram.Natarajan@Emulex.Com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:48400 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327AbYJBHTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 03:19:18 -0400
Content-Disposition: inline
In-Reply-To: <20080930030836.GE3251@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lennert.

On Tue, Sep 30, 2008 at 05:08:36AM +0200, Lennert Buytenhek (buytenh@wantstofly.org) wrote:
> > Well, this one does not have any effect, since it is not used in any
> > datapath, and I do not have mv643 boards :)
> 
> I meant to port it to one of the drivers you use, of course. :)

I can try to work with e1000 if time permits, that's the only NICs I
have connected to fast links. But main part of the sentence is "if time
permits" :)

-- 
	Evgeniy Polyakov
