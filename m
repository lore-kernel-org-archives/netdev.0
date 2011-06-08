From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Wed, 8 Jun 2011 09:08:13 -0700
Message-ID: <20110608090813.335673d9@nehalam.ftrdhcpuser.net>
References: <1307389540.2642.3.camel@edumazet-laptop>
	<20110606.130309.847468074358617705.davem@davemloft.net>
	<20110607165134.3e20bb9b@s6510.ftrdhcpuser.net>
	<20110607.172727.634954568306893152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48616 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246Ab1FHQIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 12:08:16 -0400
In-Reply-To: <20110607.172727.634954568306893152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Jun 2011 17:27:27 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 7 Jun 2011 16:51:34 -0700
> 
> > The problem is that most of the other ioctl's won't work because of use of
> > SIOCDEVPRIVATE.
> 
> As we discussed we can pass SIOCDEVPRIVATE requests down to the driver
> just like we do for all kinds of other compat ioctls.

Ok. patches accepted, but not spending my time on it.
